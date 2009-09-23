class NodesController < ApplicationController
  resources_controller_for :node

  before_filter :zip_node_parameters, :except => :index
  
  def show
    @node = Node.find(params[:id])
    respond_to do |format|
      format.html
      format.yaml  { render :text => resource.configuration.to_yaml }
    end
  end

  private

  def zip_node_parameters
    return unless params[:node] && params[:node][:parameters]
    parameter_pairs = params[:node][:parameters][:key].zip(params[:node][:parameters][:value])
    params[:node][:parameters] = Hash[parameter_pairs].reject{|k,v| k.blank?}
  end
end
