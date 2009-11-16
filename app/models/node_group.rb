class NodeGroup < ActiveRecord::Base
  include NodeGroupGraph
  has_many :node_group_class_memberships
  has_many :node_classes, :through => :node_group_class_memberships

  has_many :node_group_memberships
  has_many :nodes, :through => :node_group_memberships

  has_many :node_group_edges, :foreign_key => 'from_id'
  has_many :node_groups, :through => :node_group_edges, :source => :to

  has_parameters
  
  def description; "No description yet" end
end
