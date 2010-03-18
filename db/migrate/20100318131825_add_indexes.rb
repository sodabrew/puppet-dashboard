class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :reports, :time
    add_index :reports, :node_id
  end

  def self.down
    remove_index :reports, :node_id
    remove_index :reports, :time
  end
end
