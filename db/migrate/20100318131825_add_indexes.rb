class AddIndexes < ActiveRecord::Migration[4.2]
  def self.up
    add_index :reports, :time
    add_index :reports, :node_id
  end

  def self.down
    remove_index :reports, :node_id
    remove_index :reports, :time
  end
end
