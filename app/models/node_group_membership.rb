class NodeGroupMembership < ActiveRecord::Base
  belongs_to :node
  belongs_to :node_group
end
