require "#{RAILS_ROOT}/lib/progress_bar"

class Report < ActiveRecord::Base
  serialize :report, Puppet::Transaction::Report

  def report
    rep = read_attribute(:report)
    rep.extend(ReportExtensions) unless rep.nil? or rep.is_a? ReportExtensions
    rep
  end
end

class SchematizeReports < ActiveRecord::Migration
  def self.up
    create_table :report_logs do |t|
      t.integer :report_id, :null => false
      t.string :level
      t.string :message
      t.string :source
      t.string :tags
      t.datetime :time
      t.string :file
      t.integer :line
    end

    add_index :report_logs, [:report_id]

    create_table :resource_statuses do |t|
      t.integer :report_id, :null => false
      t.string :resource_type
      t.string :title
      t.decimal :evaluation_time, :scale => 6, :precision => 12
      t.string :file
      t.integer :line
      t.string :source_description
      t.string :tags
      t.datetime :time
      t.integer :change_count
      t.boolean :out_of_sync
    end

    add_index :resource_statuses, [:report_id]

    create_table :resource_events do |t|
      t.integer :resource_status_id, :null => false
      t.string :previous_value
      t.string :desired_value
      t.string :message
      t.string :name
      t.string :property
      t.string :source_description
      t.string :status
      t.string :tags
      t.datetime :time
    end

    add_index :resource_events, [:resource_status_id]

    create_table :metrics do |t|
      t.integer :report_id, :null => false
      t.string :category
      t.string :name
      t.decimal :value, :scale => 6, :precision => 12
    end

    add_index :metrics, [:report_id]

    # The name of this index is wrong, it's really only an index on node_id
    remove_index "reports", :name => "index_reports_on_node_id_and_success"

    remove_index "reports", ["time", "node_id", "status"]
    rename_table :reports, :old_reports

    # since all the reports are moved the nodes denormalized data needs to be adjusted
    Node.update_all({:last_report_id => nil, :reported_at => nil})

    create_table :reports do |t|
      t.integer  "node_id"
      t.string   "host"
      t.datetime "time"
      t.string   "status"
      t.string   "kind"
      t.string   "puppet_version"
      t.string   "configuration_version"
    end

    add_index "reports", ["node_id"]
    add_index "reports", ["time", "node_id", "status"]
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
