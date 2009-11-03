class NodesController < InheritedResources::Base
  respond_to :html, :yaml
  before_filter :handle_node_parameters, :only => [:create, :update]
  layout :handle_xhr

  private

  def handle_node_parameters
    handle_parameters_for(:node)
  end
  
  def content_id; :inspector end
  helper_method :content_id
end
