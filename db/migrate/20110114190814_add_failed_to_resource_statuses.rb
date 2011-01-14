class AddFailedToResourceStatuses < ActiveRecord::Migration
  def self.up
    add_column :resource_statuses, :failed, :boolean
  end

  def self.down
    remove_column :resource_statuses, :failed
  end
end
