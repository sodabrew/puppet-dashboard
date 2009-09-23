class NodeClassMembership < ActiveRecord::Base
  belongs_to :node
  belongs_to :node_class
end
