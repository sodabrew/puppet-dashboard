class NodeGroupMembership < ActiveRecord::Base
  validates_presence_of :node_id, :node_group_id

  belongs_to :node
  belongs_to :node_group
end
