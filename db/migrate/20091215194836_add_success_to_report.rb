class AddSuccessToReport < ActiveRecord::Migration[4.2]
  def self.up
    add_column :reports, :success, :boolean
  end

  def self.down
    remove_column :reports, :success
  end
end
