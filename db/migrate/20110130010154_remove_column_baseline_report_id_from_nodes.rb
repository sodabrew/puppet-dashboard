class RemoveColumnBaselineReportIdFromNodes < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :nodes, :baseline_report_id
  end

  def self.down
    add_column :nodes, :baseline_report_id, :integer
  end
end
