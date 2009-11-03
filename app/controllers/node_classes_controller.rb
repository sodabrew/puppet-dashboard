class NodeClassesController < InheritedResources::Base
  resources_controller_for :node_classes
  
  private 
  def content_id; :inspector end
  helper_method :content_id
end
