class AddSkippedToResourceStatuses < ActiveRecord::Migration
  def self.up
    add_column :resource_statuses, :skipped, :boolean
  end

  def self.down
    remove_column :resource_statuses, :skipped
  end
end
