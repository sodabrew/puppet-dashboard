class NodesController < InheritedResources::Base
  belongs_to :node_class, :optional => true
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml, :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  layout lambda {|c| c.request.xhr? ? false : 'application' }

  include ConflictAnalyzer
  include ConflictHtml

  def index
    raise NodeClassificationDisabledError.new if !SETTINGS.use_external_node_classification and request.format == :yaml
    scoped_index :unhidden
  end

  [:unreported, :failed, :unresponsive, :pending, :changed, :unchanged].each do |action|
    define_method(action) {scoped_index :unhidden, action}
  end

  def new
    new! do |format|
      format.html {
        set_group_and_class_autocomplete_data_sources(@node)
      }
    end
  end

  def create
    ActiveRecord::Base.transaction do

      create! do |success, failure|
        success.html {
          node = Node.find_by_name(params[:node][:name])

          unless(force_create?)

            new_conflicts_message = get_new_conflicts_message_as_html({}, node)
            if new_conflicts_message
              render_conflicts_html new_conflicts_message, "Create", "jQuery('#force_create').attr('value', 'true'); jQuery('#submit_button').click();"
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(node) }, :content_type => 'application/json'
        };

        failure.html {
          set_group_and_class_autocomplete_data_sources(@node)
          html = render_to_string(:template => "shared/_error",
                                  :layout => false,
                                  :locals => { :object_name => 'node', :object => @node })
          render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
        }
      end
    end
  end

  def hidden
    scoped_index :hidden
  end

  def search
    index! do |format|
      format.html {
        @search_params = params['search_params'] || []
        @search_params.delete_if {|param| param.values.any?(&:blank?)}
        nodes = @search_params.empty? ? [] : Node.find_from_inventory_search(@search_params)
        set_collection_ivar(nodes)
        render :inventory_search
      }
    end
  end

  def show
    begin
      raise NodeClassificationDisabledError.new if !SETTINGS.use_external_node_classification and request.format == :yaml
      show!
    rescue ActiveRecord::RecordNotFound => e
      raise e unless request.format == :yaml
      render :yaml => {'classes' => []}
    rescue ParameterConflictError => e
      raise e unless request.format == :yaml
      render :text => "Node \"#{resource.name}\" has conflicting variable(s): #{resource.errors[:parameters].to_a.to_sentence}", :content_type => 'text/plain', :status => 500
    rescue ClassParameterConflictError => e
      raise e unless request.format == :yaml
      render :text => "Node \"#{resource.name}\" has conflicting class parameter(s): #{resource.errors[:classParameters].to_a.to_sentence}", :content_type => 'text/plain', :status => 500
    rescue NodeClassificationDisabledError => e
      render :text => "Node classification has been disabled", :content_type => 'text/plain', :status => 403
    end
  end

  def edit
    edit! do |format|
      format.html {
        set_group_and_class_autocomplete_data_sources(@node)
      }
    end
  end

  def update
    ActiveRecord::Base.transaction do
      old_conflicts = force_update? ? nil : get_current_conflicts(Node.find_by_id(params[:id]))

      update! do |success, failure|
        success.html {
          node = Node.find_by_id(params[:id])

          unless(force_update?)

            new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, node)
            if new_conflicts_message
              render_conflicts_html new_conflicts_message, "Update", "jQuery('#force_update').attr('value', 'true'); jQuery('#submit_button').click();"
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(node) }, :content_type => 'application/json'
        };

        failure.html {
          node = Node.find_by_id(params[:id])

          set_group_and_class_autocomplete_data_sources(node)
          html = render_to_string(:template => "shared/_error",
                                  :layout => false,
                                  :locals => { :object_name => 'node', :object => node })
          render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
        }
      end
    end
  end

  def hide
    respond_to do |format|
      resource.hidden = true
      resource.save!

      format.html { redirect_to node_path(resource) }
    end
  end

  def unhide
    respond_to do |format|
      resource.hidden = false
      resource.save!

      format.html { redirect_to node_path(resource) }
    end
  end

  def facts
    respond_to do |format|
      format.html {
        begin
          render :partial => 'nodes/facts', :locals => {:node => resource, :facts => resource.facts}
        rescue => e
          render :text => "Could not retrieve facts from inventory service: #{e.message}"
        end
      }
    end
  end

  # TODO: routing currently can't handle nested resources due to node's id
  # requirements
  def reports
    @node = resource
    @reports = params[:kind] == "inspect" ? @node.reports.inspections : @node.reports.applies
    respond_to do |format|
      format.html { @reports = paginate_scope(@reports); render 'reports/index' }
    end
  end

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_id_or_name!(params[:id]))
  end

  # Render the index using the +scope_name+ (e.g. :successful for Node.successful).
  def scoped_index(*scope_names)
    index! do |format|
      scope = end_of_association_chain
      if params[:q]
        scope = scope.search(params[:q])
      end
      scope_names.each do |scope_name|
        scope = scope.send(scope_name)
      end
      set_collection_ivar(scope.with_last_report.by_report_date)

      format.html { render :index }
      format.json { render :json => collection }
      format.yaml { render :yaml => collection }
      format.csv {
        expires_in 0, 'must-revalidate' => true, :private => true
        render :csv => collection, :filename => "#{scope_names.join('-')}-nodes"
      }
    end
  end

end
