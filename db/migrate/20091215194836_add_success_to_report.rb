class AddSuccessToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :success, :boolean
  end

  def self.down
    remove_column :reports, :success
  end
end
