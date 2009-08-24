class ConvertHostsToNodes < ActiveRecord::Migration
  def self.up
    rename_table :hosts, :nodes
    rename_column :assignments, :host_id, :node_id
  end

  def self.down
    rename_column :assignments, :node_id, :host_id
    rename_table :nodes, :hosts
  end
end
