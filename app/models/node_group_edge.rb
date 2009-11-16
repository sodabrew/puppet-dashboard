class NodeGroupEdge < ActiveRecord::Base
  belongs_to :to, :class_name => 'NodeGroup'
  belongs_to :from, :class_name => 'NodeGroup'
end
