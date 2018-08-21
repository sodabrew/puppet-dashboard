class RemoveSourceDescriptionFromResourceStatuses < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :resource_statuses, :source_description
  end

  def self.down
    add_column :resource_statuses, :source_description, :string
  end
end
