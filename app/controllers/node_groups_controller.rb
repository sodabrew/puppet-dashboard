class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json

  private

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.search(params[:q]).paginate(:page => params[:page]))
  end
end
