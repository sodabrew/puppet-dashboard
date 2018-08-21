class AddFailedToResourceStatuses < ActiveRecord::Migration[4.2]
  def self.up
    add_column :resource_statuses, :failed, :boolean
  end

  def self.down
    remove_column :resource_statuses, :failed
  end
end
