class CreateNodeGroupMemberships < ActiveRecord::Migration[4.2]
  def self.up
    create_table :node_group_memberships do |t|
      t.integer :node_id
      t.integer :node_group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :node_group_memberships
  end
end
