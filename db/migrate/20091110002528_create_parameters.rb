class CreateParameters < ActiveRecord::Migration
  def self.up
    create_table :parameters do |t|
      t.string :key
      t.text :value
      t.integer :parameterable_id
      t.string :parameterable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :parameters
  end
end
