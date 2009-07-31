class CreateInstances < ActiveRecord::Migration
  def self.up
    create_table :instances, :force => true do |t|
      t.string  :name
      t.boolean :is_active
      t.integer :app_id
      t.timestamps
    end
  end

  def self.down
    drop_table :instances
  end
end
