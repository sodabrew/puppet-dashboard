class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps, :force => true do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :apps
  end
end
