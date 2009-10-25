class NodeGroup < ActiveRecord::Base
  has_many :node_group_class_memberships
  has_many :node_classes, :through => :node_group_class_memberships
end
