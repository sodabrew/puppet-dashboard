class AddHiddenToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :nodes, :hidden
  end
end
