class AddAuditedToResourceEvents < ActiveRecord::Migration[4.2]
  def self.up
    add_column :resource_events, :audited, :boolean
  end

  def self.down
    remove_column :resource_events, :audited
  end
end
