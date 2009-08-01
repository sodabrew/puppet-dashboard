class ChangeAppToInstanceForDeployments < ActiveRecord::Migration
  def self.up
    add_column :deployments, :instance_id, :integer
    remove_column :deployments, :app_id
  end

  def self.down
    add_column :deployments, :app_id, :integer
    remove_column :deployments, :instance_id
  end
end
