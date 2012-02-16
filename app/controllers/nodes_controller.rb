class NodesController < InheritedResources::Base
  belongs_to :node_class, :optional => true
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml, :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  layout lambda {|c| c.request.xhr? ? false : 'application' }

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
    create! do |success, failure|
      failure.html {
        set_group_and_class_autocomplete_data_sources(@node)
        render :new
      }
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
      node = {'classes' => []}
      render :text => node.to_yaml, :content_type => 'application/x-yaml'
    rescue ParameterConflictError => e
      raise e unless request.format == :yaml
      render :text => "Node \"#{resource.name}\" has conflicting parameter(s): #{resource.errors.on(:parameters).to_a.to_sentence}", :content_type => 'text/plain', :status => 500
    rescue NodeClassificationDisabledError => e
      render :text => "Node classification has been disabled", :content_type => 'text/plain', :status => 403
    end
  end

  def edit
    # Make the node name readonly
    @readonly_name = "readonly"
    edit! do |format|
      format.html {
        set_group_and_class_autocomplete_data_sources(@node)
      }
    end
  end

  def update
    update! do |success, failure|
      failure.html {
        set_group_and_class_autocomplete_data_sources(@node)
        render :edit
      }
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
      format.json { render :text => collection.to_json, :content_type => 'application/json' }
      format.yaml { render :text => collection.to_yaml, :content_type => 'application/x-yaml' }
      format.csv do
        response["Cache-Control"] = 'must-revalidate, post-check=0, pre-check=0'
        response["Content-Type"] = 'text/comma-separated-values;'
        response["Content-Disposition"] = "attachment;filename=#{scope_names.join("-")}-nodes.csv;"

        render :text => proc { |response,output|
          collection.to_csv do |line|
            output.write(line)
          end
        }, :layout => false
      end
    end
  end
end
