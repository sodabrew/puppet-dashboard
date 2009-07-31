class CreateDestinations < ActiveRecord::Migration
  def self.up
    create_table :destinations, :force => true do |t|
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :destinations
  end
end
