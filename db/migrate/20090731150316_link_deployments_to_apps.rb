class LinkDeploymentsToApps < ActiveRecord::Migration
  def self.up
    add_column :deployments, :app_id, :integer
  end

  def self.down
    remove_column :deployments, :app_id
  end
end
