class CreateNodeGroups < ActiveRecord::Migration
  def self.up
    create_table :node_groups do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :node_groups
  end
end
