require "#{RAILS_ROOT}/lib/progress_bar"

class AddStatusToReports < ActiveRecord::Migration
  class Node < ActiveRecord::Base
    belongs_to :last_report, :class_name => 'Report'
  end

  def self.up
    add_column :reports, :status, :string
    add_index :reports, [:time, :node_id, :status]

    remove_index :reports, [:time, :node_id, :success]
    remove_column :reports, :success

    add_column :nodes, :status, :string
    remove_column :nodes, :success
  end

  def self.down
    add_column :reports, :success, :boolean
    add_index :reports, [:time, :node_id, :success]
    Report.update_all({:success => true}, "status != 'failed'")
    Report.update_all({:success => false}, "status = 'failed'")
    remove_index :reports, [:time, :node_id, :status]
    remove_column :reports, :status

    add_column :nodes, :success, :boolean, :default => false
    Node.all.each do |node|
      node.success = node.last_report ? node.last_report.success : false
      node.save
    end
    remove_column :nodes, :status
  end
end
