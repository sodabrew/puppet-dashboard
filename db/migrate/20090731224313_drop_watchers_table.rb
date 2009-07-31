class DropWatchersTable < ActiveRecord::Migration
  def self.up
    drop_table :watchers
  end

  def self.down
    create_table "watchers", :force => true do |t|
      t.boolean  "is_active"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
