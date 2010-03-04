class NodesController < InheritedResources::Base
  belongs_to :node_class, :optional => true
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml

  layout lambda {|c| c.request.xhr? ? false : 'application' }

  def successful
    @nodes = Node.successful.paginate(:page => params[:page])
    render :index
  end

  def failed
    @nodes = Node.failed.paginate(:page => params[:page])
    render :index
  end

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_name!(params[:id]))
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.by_report_date.paginate(:page => params[:page]))
  end
end
