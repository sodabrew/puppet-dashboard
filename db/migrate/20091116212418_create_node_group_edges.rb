class CreateNodeGroupEdges < ActiveRecord::Migration
  def self.up
    create_table :node_group_edges do |t|
      t.integer :to_id
      t.integer :from_id

      t.timestamps
    end
  end

  def self.down
    drop_table :node_group_edges
  end
end
