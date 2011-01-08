class RemoveOutOfSyncColumn < ActiveRecord::Migration
  def self.up
    remove_column :resource_statuses, :out_of_sync
  end

  def self.down
    add_column :resource_statuses, :out_of_sync, :boolean
  end
end
