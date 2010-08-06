class CleanupNodeMemberships < ActiveRecord::Migration
  def self.up
    NodeClassMembership.all.each do |n|
      n.destroy if n.node_class.nil? || n.node.nil?
    end
    NodeGroupMembership.all.each do |n|
      n.destroy if n.node_group.nil? || n.node.nil?
    end
    NodeGroupClassMembership.all.each do |n|
      n.destroy if n.node_group.nil? || n.node_class.nil?
    end
    NodeGroupEdge.all.each do |n|
      n.destroy if n.to.nil? || n.from.nil?
    end
  end

  def self.down
    # Can't restore orphaned associations, but why would you want to?
  end
end
