class AddSkippedToResourceStatuses < ActiveRecord::Migration[4.2]
  def self.up
    add_column :resource_statuses, :skipped, :boolean
  end

  def self.down
    remove_column :resource_statuses, :skipped
  end
end
