class NodesController < InheritedResources::Base
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml

  before_filter :find_node_groups, :only => [:update, :create]
  before_filter :find_node_classes, :only => [:update, :create]

  def create
    create!
    @node.node_groups << parent if parent?
  end

  private

  def content_id; :inspector end
  helper_method :content_id

  def find_node_classes
    return true unless ids = params[:node] && params[:node][:node_classes]
    params[:node][:node_classes] = NodeClass.find(ids)
  end

  def find_node_groups
    return true unless ids = params[:node] && params[:node][:node_groups]
    params[:node][:node_groups] = NodeGroup.find(ids)
  end
end
