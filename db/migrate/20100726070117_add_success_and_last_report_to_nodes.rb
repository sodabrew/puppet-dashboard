class AddSuccessAndLastReportToNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :success, :boolean, :default => false
    add_column :nodes, :last_report_id, :integer

    Node.reset_column_information

    require "#{Rails.root}/lib/progress_bar"
    nodes = Node.all.to_a
    if nodes.size > 0
      pbar = ProgressBar.new("Migrating:", nodes.size, STDOUT)
      nodes.each do |node|
        report = node.find_last_report
        pbar.inc
        next unless report
        report.send(:update_node, true)
      end
      pbar.finish
    end
  end

  def self.down
    remove_column :nodes, :success
  end
end
