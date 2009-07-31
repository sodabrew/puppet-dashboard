class LinkingDeploymentsWithHosts < ActiveRecord::Migration
  def self.up
    add_column :deployments, :host_id, :integer
  end

  def self.down
    remove_column :deployments, :host_id
  end
end
