class RemoveUnusedTablesAndModels < ActiveRecord::Migration
  def self.up
    drop_table :assignments
    drop_table :services
  end

  def self.down
    create_table :assignments, :force => true do |t|
      t.integer  :node_id
      t.integer  :service_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :services, :force => true do |t|
      t.string   :name
      t.string   :type
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
