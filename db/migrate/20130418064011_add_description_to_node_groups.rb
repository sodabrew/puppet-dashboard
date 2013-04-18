class AddDescriptionToNodeGroups < ActiveRecord::Migration
  def change
    add_column :node_groups, :description, :text
  end
end
