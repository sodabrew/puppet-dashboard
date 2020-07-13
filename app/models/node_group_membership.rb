class NodeGroupMembership < ApplicationRecord
  validates_uniqueness_of :node_id, :scope => :node_group_id

  belongs_to :node, required: true
  belongs_to :node_group, required: true

  def to_json(*args)
    {"node_group_id" => node_group_id, "node_id" => node_id}.to_json(*args)
  end
end
