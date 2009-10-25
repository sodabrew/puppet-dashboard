class NodeGroupsController < ApplicationController
  resources_controller_for :node_groups

  before_filter :handle_parameters, :only => [:create, :update]

  private

  def handle_parameters
    if params[:node_group] && params[:node_group][:parameters]
      parameter_pairs = params[:node_group][:parameters][:key].zip(params[:node_group][:parameters][:value]).flatten
      params[:node_group][:parameters] = Hash[*parameter_pairs].reject{|k,v| k.blank?}
    else
      params[:node_group][:parameters] = {}
    end
  end
end
