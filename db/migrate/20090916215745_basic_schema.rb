class BasicSchema < ActiveRecord::Migration
  def self.up
    create_table :assignments, :force => true do |t|
      t.integer  :node_id
      t.integer  :service_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :nodes, :force => true do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.text     :parameters
    end

    create_table :services, :force => true do |t|
      t.string   :name
      t.string   :type
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :assignments
    drop_table :ndoes
    drop_table :services
  end
end
