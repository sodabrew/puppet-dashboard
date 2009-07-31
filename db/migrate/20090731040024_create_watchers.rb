class CreateWatchers < ActiveRecord::Migration
  def self.up
    create_table :watchers, :force => true do |t|
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :watchers
  end
end
