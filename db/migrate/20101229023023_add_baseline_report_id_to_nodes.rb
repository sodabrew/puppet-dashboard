class AddBaselineReportIdToNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :baseline_report_id, :integer
  end

  def self.down
    remove_column :nodes, :baseline_report_id
  end
end
