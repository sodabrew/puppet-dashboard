class NodeGroupClassMembership < ActiveRecord::Base
  belongs_to :node_class
  belongs_to :node_group
end
