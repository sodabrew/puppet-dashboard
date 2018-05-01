class AddOutOfSyncCountToResourceStatuses < ActiveRecord::Migration[4.2]
  def self.up
    add_column :resource_statuses, :out_of_sync_count, :integer
  end

  def self.down
    remove_column :resource_statuses, :out_of_sync_count
  end
end
