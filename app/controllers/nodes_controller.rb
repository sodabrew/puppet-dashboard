class NodesController < InheritedResources::Base
  belongs_to :node_class, :optional => true
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml, :json

  layout lambda {|c| c.request.xhr? ? false : 'application' }

  def index
    scoped_index
  end

  def successful
    redirect_to nodes_path(:current => true.to_s, :successful => true.to_s)
  end

  def failed
    redirect_to nodes_path(:current => true.to_s, :successful => false.to_s)
  end

  def unreported
    scoped_index :unreported
  end

  def no_longer_reporting
    scoped_index :no_longer_reporting
  end

  def show
    begin
      show!
    rescue ActiveRecord::RecordNotFound => e
      raise e unless request.format == :yaml
      node = {'classes' => []}
      render :text => node.to_yaml, :content_type => 'application/x-yaml'
    rescue ParameterConflictError => e
      raise e unless request.format == :yaml
      render :text => "Node \"#{resource.name}\" has conflicting parameter(s): #{resource.errors.on(:parameters).to_a.to_sentence}", :content_type => 'text/plain', :status => 500
    end
  end

  # TODO: routing currently can't handle nested resources due to node's id
  # requirements
  def reports
    @node = resource
    @reports = @node.reports
    respond_to do |format|
      format.html { @reports = paginate_scope(@reports); render 'reports/index' }
      format.yaml { render :text => @reports.to_yaml, :content_type => 'application/x-yaml' }
      format.json { render :json => @reports.to_json }
    end
  end

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_name!(params[:id]))
  end

  # Render the index using the +scope_name+ (e.g. :successful for Node.successful).
  def scoped_index(scope_name=nil)
    index! do |format|
      scope = end_of_association_chain
      if params[:q]
        scope = scope.search(params[:q])
      end
      if scope_name
        scope = scope.send(scope_name)
      end
      if params[:current].present? or params[:successful].present?
        scope = scope.by_currentness_and_successfulness(params[:current] == "true", params[:successful] == "true")
      end
      set_collection_ivar(scope.with_last_report.by_report_date)

      format.html { render :index }
      format.yaml { render :text => collection.to_yaml, :content_type => 'application/x-yaml' }
      format.json { render :json => collection.to_json }
    end
  end
end
