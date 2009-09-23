class CreateNodeClassMemberships < ActiveRecord::Migration
  def self.up
    create_table :node_class_memberships do |t|
      t.integer :node_id
      t.integer :node_class_id

      t.timestamps
    end
  end

  def self.down
    drop_table :node_class_memberships
  end
end
