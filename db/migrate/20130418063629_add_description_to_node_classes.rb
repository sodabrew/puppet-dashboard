class AddDescriptionToNodeClasses < ActiveRecord::Migration[4.2]
  def change
    add_column :node_classes, :description, :text
  end
end
