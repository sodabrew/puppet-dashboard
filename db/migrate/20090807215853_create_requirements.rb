class CreateRequirements < ActiveRecord::Migration
  def self.up
    create_table :requirements, :force => true do |t|
      t.integer :instance_id, :service_id
      t.timestamps
    end
  end

  def self.down
    drop_table :requirements
  end
end
