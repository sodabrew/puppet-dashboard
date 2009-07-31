class CreateDeployments < ActiveRecord::Migration
  def self.up
    create_table :deployments, :force => true do |t|
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :deployments
  end
end
