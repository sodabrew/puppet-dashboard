class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :edges, :force => true do |t|
      t.integer :source_id, :target_id
      t.timestamps
    end
  end

  def self.down
    drop_table :edges
  end
end
