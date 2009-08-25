class NodesController < ApplicationController
  resources_controller_for :node
  
  def show
    @node = Node.find(params[:id])
    respond_to do |format|
      format.html
      format.yaml  { render :text => resource.configuration.to_yaml }
    end
  end
  
  def edit
    @node = Node.find(params[:id])
  end
end
