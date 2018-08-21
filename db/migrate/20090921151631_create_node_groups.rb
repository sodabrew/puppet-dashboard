class CreateNodeGroups < ActiveRecord::Migration[4.2]
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
