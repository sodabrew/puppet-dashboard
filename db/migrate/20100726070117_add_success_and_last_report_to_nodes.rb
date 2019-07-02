class AddSuccessAndLastReportToNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :success, :boolean, :default => false
    add_column :nodes, :last_report_id, :integer

    Node.reset_column_information

    nodes = Node.all.to_a
    if nodes.size > 0
      pbar = ProgressBar.create(title: 'Migrating', total: nodes.size)
      nodes.each do |node|
        report = node.find_last_report
        pbar.increment
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
