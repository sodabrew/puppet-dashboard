class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts, :force => true do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :hosts
  end
end
