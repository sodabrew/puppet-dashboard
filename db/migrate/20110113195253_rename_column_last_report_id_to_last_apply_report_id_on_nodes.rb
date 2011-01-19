class RenameColumnLastReportIdToLastApplyReportIdOnNodes < ActiveRecord::Migration
  def self.up
    rename_column :nodes, :last_report_id, :last_apply_report_id
  end

  def self.down
    rename_column :nodes, :last_apply_report_id, :last_report_id
  end
end
