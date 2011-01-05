class RemoveTagsFromResourceEvents < ActiveRecord::Migration
  def self.up
    remove_column :resource_events, :tags
  end

  def self.down
    add_column :resource_events, :tags, :string
  end
end
