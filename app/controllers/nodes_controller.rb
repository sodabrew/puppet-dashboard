class NodesController < InheritedResources::Base
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml

  before_filter :find_node_groups, :only => [:update, :create]
  before_filter :find_node_classes, :only => [:update, :create]

  def create
    create!
    resource.node_groups << parent if parent?
  end

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_name!(params[:id]))
  end

  private

  def content_id; :inspector end
  helper_method :content_id

  def find_node_classes
    params[:node][:node_classes] ||= []
    return if params[:node][:node_classes].empty?
    params[:node][:node_classes] = NodeClass.find(params[:node][:node_classes])
  end

  def find_node_groups
    params[:node][:node_groups] ||= []
    return if params[:node][:node_groups].empty?
    params[:node][:node_groups] = NodeGroup.find(params[:node][:node_groups])
  end
end
