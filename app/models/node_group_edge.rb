class NodeGroupEdge < ActiveRecord::Base
  validates_presence_of :to_id, :from_id

  belongs_to :to, :class_name => 'NodeGroup'
  belongs_to :from, :class_name => 'NodeGroup'
end
