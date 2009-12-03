class NodeClassesController < InheritedResources::Base
  resources_controller_for :node_classes

  def search
    @node_classes = NodeClass.search(params[:val])
    render :json => @node_classes.to_json
  end

  private 
  def content_id; :inspector end
  helper_method :content_id
end
