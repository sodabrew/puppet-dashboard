class NodeGroupClassMembership < ApplicationRecord
  include NodeGroupGraph

  has_parameters

  belongs_to :node_class, required: true
  belongs_to :node_group, required: true
end
