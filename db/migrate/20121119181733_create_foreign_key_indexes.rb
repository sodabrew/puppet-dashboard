class CreateForeignKeyIndexes < ActiveRecord::Migration
  def self.up
    add_index :node_group_memberships, :node_group_id
    add_index :node_group_memberships, :node_id
    add_index :node_group_class_memberships, :node_group_id
    add_index :node_group_class_memberships, :node_class_id
    add_index :node_class_memberships, :node_id
    add_index :node_class_memberships, :node_class_id
    add_index :node_group_edges, :from_id
    add_index :node_group_edges, :to_id
    add_index :parameters, [:parameterable_type, :parameterable_id]
  end

  def self.down
    remove_index :node_group_memberships, :node_group_id
    remove_index :node_group_memberships, :node_id
    remove_index :node_group_class_memberships, :node_group_id
    remove_index :node_group_class_memberships, :node_class_id
    remove_index :node_class_memberships, :node_id
    remove_index :node_class_memberships, :node_class_id
    remove_index :node_group_edges, :from_id
    remove_index :node_group_edges, :to_id
    remove_index :parameters, [:parameterable_type, :parameterable_id]
  end
end
