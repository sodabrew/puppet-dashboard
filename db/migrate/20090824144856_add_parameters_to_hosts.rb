class AddParametersToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :parameters, :text
  end

  def self.down
    remove_column :hosts, :parameters
  end
end
