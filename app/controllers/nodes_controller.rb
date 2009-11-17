class NodesController < InheritedResources::Base
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml

  def create
    create!
    @node.node_groups << parent if parent?
  end

  private

  def content_id; :inspector end
  helper_method :content_id
end
