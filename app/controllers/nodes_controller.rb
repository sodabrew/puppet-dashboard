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
  
  def update
    @node = Node.find(params[:id])
    params[:node]['parameters'] = unserialize_parameters_data(params) if params[:node]  
    
    if @node.update_attributes(params[:node])
      flash[:notice] = "Node was successfully updated."
      redirect_to resource_url
    else
      render :action => 'edit'
    end
  end
  
  private
  
  def unserialize_parameters_data(params)
    return {} unless params[:node]['parameters'] and params[:node]['parameters']['key'] and params[:node]['parameters']['value']
    params[:node]['parameters']['key'].zip(params[:node]['parameters']['value']).inject({}) do |h, pair|
      h[pair.first] = pair.last unless pair.first.blank?
      h
    end
  end    
end
