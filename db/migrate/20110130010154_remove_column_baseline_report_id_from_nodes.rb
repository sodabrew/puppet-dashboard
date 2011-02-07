class RemoveColumnBaselineReportIdFromNodes < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :baseline_report_id
  end

  def self.down
    add_column :nodes, :baseline_report_id, :integer
  end
end
