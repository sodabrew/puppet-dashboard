class NodesController < ApplicationController
  resources_controller_for :node
  before_filter :handle_node_parameters, :only => [:create, :update]

  def show
    @node = Node.find(params[:id])
    respond_to do |format|
      format.html
      format.yaml  { render :text => resource.configuration.to_yaml }
    end
  end

  private

  def handle_node_parameters
    if params[:node] && params[:node][:parameters]
      parameter_pairs = params[:node][:parameters][:key].zip(params[:node][:parameters][:value]).flatten
      params[:node][:parameters] = Hash[*parameter_pairs].reject{|k,v| k.blank?}
    else
      params[:node][:parameters] = {}
    end
  end
end
