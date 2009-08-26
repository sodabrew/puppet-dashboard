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
    @available_services = (Service.all - @node.services) # obviously we must paginate and/or search soon.
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
  
  # connect a service to this node
  def connect
    @service = Service.find(params[:service_id])
    @node = Node.find(params[:id])
    @node.services << @service
    @available_services = (Service.all - @node.services) # obviously we must paginate and/or search soon.
    render :layout => false
  end
  
  # disconnect a service from this node
  def disconnect
    @service = Service.find(params[:service_id])
    @node = Node.find(params[:id])
    @node.services.delete(@service)
    @available_services = (Service.all - @node.services) # obviously we must paginate and/or search soon.
    render :layout => false
  end
  
  private
  
  # take key-value data from params[:node]['parameters'] and return the corresponding node#parameters hash
  def unserialize_parameters_data(params)
    return {} unless params[:node]['parameters'] and params[:node]['parameters']['key'] and params[:node]['parameters']['value']
    params[:node]['parameters']['key'].zip(params[:node]['parameters']['value']).inject({}) do |h, pair|
      h[pair.first] = pair.last unless pair.first.blank?
      h
    end
  end    
end
