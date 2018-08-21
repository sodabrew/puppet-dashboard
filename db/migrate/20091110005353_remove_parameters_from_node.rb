class RemoveParametersFromNode < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :nodes, :parameters
  end

  def self.down
    add_column :nodes, :parameters, :text
  end
end
