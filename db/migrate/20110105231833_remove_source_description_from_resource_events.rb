class RemoveSourceDescriptionFromResourceEvents < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :resource_events, :source_description
  end

  def self.down
    add_column :resource_events, :source_description, :string
  end
end
