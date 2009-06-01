class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services, :force => true do |t|
      t.string :name, :type
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
