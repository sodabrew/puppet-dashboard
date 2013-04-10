class NodeGroupClassMembership < ActiveRecord::Base
  validates_presence_of :node_class_id, :node_group_id

  include NodeGroupGraph

  has_parameters

  attr_accessible :parameter_attributes

  belongs_to :node_class
  belongs_to :node_group

  attr_accessible :node_class, :node_class_id, :node_class_ids
end
