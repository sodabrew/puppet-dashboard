class RemoveSourceDescriptionFromResourceStatuses < ActiveRecord::Migration
  def self.up
    remove_column :resource_statuses, :source_description
  end

  def self.down
    add_column :resource_statuses, :source_description, :string
  end
end
