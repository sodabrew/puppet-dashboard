class AddDescriptionToNodeGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :node_groups, :description, :text
  end
end
