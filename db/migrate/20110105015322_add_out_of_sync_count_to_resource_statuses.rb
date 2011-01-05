class AddOutOfSyncCountToResourceStatuses < ActiveRecord::Migration
  def self.up
    add_column :resource_statuses, :out_of_sync_count, :integer
  end

  def self.down
    remove_column :resource_statuses, :out_of_sync_count
  end
end
