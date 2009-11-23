class NodeClassesController < InheritedResources::Base
  resources_controller_for :node_classes

  def search
    @node_classes = NodeClass.search(params[:q])
    @node_classes = [] if params[:q].blank?
    render :layout => false
  end

  private 
  def content_id; :inspector end
  helper_method :content_id
end
