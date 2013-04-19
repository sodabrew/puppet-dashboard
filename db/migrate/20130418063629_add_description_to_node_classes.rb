class AddDescriptionToNodeClasses < ActiveRecord::Migration
  def change
    add_column :node_classes, :description, :text
  end
end
