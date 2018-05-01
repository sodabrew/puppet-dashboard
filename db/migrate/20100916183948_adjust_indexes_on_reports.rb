class AdjustIndexesOnReports < ActiveRecord::Migration[4.2]
  def self.up
    remove_index :reports, :time

    add_index :reports, [:time, :node_id, :success]
  end

  def self.down
    remove_index :reports, [:time, :node_id, :success]

    add_index :reports, :time
  end
end
