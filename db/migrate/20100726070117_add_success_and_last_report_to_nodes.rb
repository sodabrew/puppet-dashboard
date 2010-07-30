class AddSuccessAndLastReportToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :success, :boolean, :default => false
    add_column :nodes, :last_report_id, :integer

    Node.reset_column_information

    require "#{RAILS_ROOT}/lib/progress_bar"
    nodes = Node.all
    pbar = ProgressBar.new("Migrating:", nodes.size, STDOUT)
    nodes.each do |node|
      report = node.find_last_report
      pbar.inc
      next unless report
      report.send(:update_node, true)
    end
    pbar.finish
  end

  def self.down
    remove_column :nodes, :success
  end
end
