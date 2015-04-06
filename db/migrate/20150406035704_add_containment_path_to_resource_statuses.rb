class AddContainmentPathToResourceStatuses < ActiveRecord::Migration
  def change
    add_column :resource_statuses, :containment_path, :text
  end
end
