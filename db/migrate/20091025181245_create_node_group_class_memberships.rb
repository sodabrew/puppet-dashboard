class CreateNodeGroupClassMemberships < ActiveRecord::Migration[4.2]
  def self.up
    create_table :node_group_class_memberships do |t|
      t.belongs_to :node_group
      t.belongs_to :node_class

      t.timestamps
    end
  end

  def self.down
    drop_table :node_group_class_memberships
  end
end
