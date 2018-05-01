class AddLastInspectReportIdToNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :last_inspect_report_id, :integer
  end

  def self.down
    remove_column :nodes, :last_inspect_report_id
  end
end
