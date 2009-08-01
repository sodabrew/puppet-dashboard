class MoveServiceIdFromAppToInstance < ActiveRecord::Migration
  def self.up
    add_column :instances, :service_id, :integer
    remove_column :apps, :service_id
  end

  def self.down
    add_column :apps, :service_id, :integer
    remove_column :instances, :service_id
  end
end
