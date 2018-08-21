class AddSuccessToReportIndex < ActiveRecord::Migration[4.2]
  def self.up
    remove_index :reports, :node_id
    add_index :reports, [:node_id, :success]
  end

  def self.down
    remove_index :reports, [:node_id, :success]
    add_index :reports, :node_id
  end
end
