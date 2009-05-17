class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers, :force => true do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
