class NodeClassesController < ApplicationController
  resources_controller_for :node_classes
  layout "primary_secondary"
  
  private 
  def content_id
    :inspector
  end
  helper_method :content_id
end
