class AddParametersToInstances < ActiveRecord::Migration
  def self.up
    add_column :instances, :parameters, :text
  end

  def self.down
    remove_column :instances, :parameters
  end
end
