class AddLastInspectReportIdToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :last_inspect_report_id, :integer
  end

  def self.down
    remove_column :nodes, :last_inspect_report_id
  end
end
