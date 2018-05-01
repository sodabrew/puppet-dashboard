class RemoveParametersFromNodeGroups < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :node_groups, :parameters
  end

  def self.down
    add_column :node_groups, :parameters, :text
  end
end
