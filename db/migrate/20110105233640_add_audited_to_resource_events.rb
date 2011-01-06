class AddAuditedToResourceEvents < ActiveRecord::Migration
  def self.up
    add_column :resource_events, :audited, :boolean
  end

  def self.down
    remove_column :resource_events, :audited
  end
end
