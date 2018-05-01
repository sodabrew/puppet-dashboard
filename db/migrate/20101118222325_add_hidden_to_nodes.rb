class AddHiddenToNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :nodes, :hidden
  end
end
