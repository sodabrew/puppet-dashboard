class RenameColumnLastReportIdToLastApplyReportIdOnNodes < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :nodes, :last_report_id, :last_apply_report_id
  end

  def self.down
    rename_column :nodes, :last_apply_report_id, :last_report_id
  end
end
