class ConnectAppsToServices < ActiveRecord::Migration
  def self.up
    add_column :apps, :service_id, :integer
  end

  def self.down
    remove_column :apps, :service_id
  end
end
