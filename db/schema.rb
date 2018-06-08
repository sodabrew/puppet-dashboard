# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150406035704) do

  postgres = ActiveRecord::Base.connection.adapter_name.downcase =~ /postgres/

  create_table "delayed_job_failures", :force => true do |t|
    t.string   "summary"
    t.text     "details"
    t.boolean  "read",       :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "backtrace"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                       :default => 0
    t.integer  "attempts",                       :default => 0
    t.text     "handler",    :limit => 16777216			unless postgres
    t.text     "handler"					if postgres
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["failed_at", "run_at", "locked_at", "locked_by"], :name => "index_delayed_jobs_multi"
  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "metrics", :force => true do |t|
    t.integer "report_id",                                :null => false
    t.string  "category"
    t.string  "name"
    t.decimal "value",     :precision => 12, :scale => 6
  end

  add_index "metrics", ["report_id", "category", "name"], :name => "index_metrics_multi"
  add_index "metrics", ["report_id"], :name => "index_metrics_on_report_id"

  create_table "node_class_memberships", :force => true do |t|
    t.integer  "node_id"
    t.integer  "node_class_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "node_class_memberships", ["node_class_id"], :name => "index_node_class_memberships_on_node_class_id"
  add_index "node_class_memberships", ["node_id"], :name => "index_node_class_memberships_on_node_id"

  create_table "node_classes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "node_group_class_memberships", :force => true do |t|
    t.integer  "node_group_id"
    t.integer  "node_class_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "node_group_class_memberships", ["node_class_id"], :name => "index_node_group_class_memberships_on_node_class_id"
  add_index "node_group_class_memberships", ["node_group_id"], :name => "index_node_group_class_memberships_on_node_group_id"

  create_table "node_group_edges", :force => true do |t|
    t.integer  "to_id"
    t.integer  "from_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "node_group_edges", ["from_id"], :name => "index_node_group_edges_on_from_id"
  add_index "node_group_edges", ["to_id"], :name => "index_node_group_edges_on_to_id"

  create_table "node_group_memberships", :force => true do |t|
    t.integer  "node_id"
    t.integer  "node_group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "node_group_memberships", ["node_group_id"], :name => "index_node_group_memberships_on_node_group_id"
  add_index "node_group_memberships", ["node_id"], :name => "index_node_group_memberships_on_node_id"

  create_table "node_groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.string   "environment"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reported_at"
    t.integer  "last_apply_report_id"
    t.string   "status"
    t.boolean  "hidden",                 :default => false
    t.integer  "last_inspect_report_id"
  end

  add_index "nodes", ["last_apply_report_id"], :name => "index_nodes_on_last_apply_report_id"
  add_index "nodes", ["name"], :name => "uc_node_name", :unique => true

  create_table "old_reports", :force => true do |t|
    t.integer  "node_id"
    t.text     "report"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "host"
    t.datetime "time"
    t.string   "status"
  end

  create_table "parameters", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.integer  "parameterable_id"
    t.string   "parameterable_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "parameters", ["parameterable_id", "parameterable_type", "key"], :name => "index_parameters_multi"

  create_table "report_logs", :force => true do |t|
    t.integer  "report_id",                :null => false
    t.string   "level"
    t.text     "message",   :limit => 255			unless postgres
    t.text     "message"					if postgres
    t.text     "source",    :limit => 255			unless postgres
    t.text     "source"						if postgres
    t.text     "tags",      :limit => 255			unless postgres
    t.text     "tags"						if postgres
    t.datetime "time"
    t.text     "file",      :limit => 255			unless postgres
    t.text     "file"						if postgres
    t.integer  "line"
  end

  add_index "report_logs", ["report_id"], :name => "index_report_logs_on_report_id"

  create_table "reports", :force => true do |t|
    t.integer  "node_id"
    t.string   "host"
    t.datetime "time"
    t.string   "status"
    t.string   "kind"
    t.string   "puppet_version"
    t.string   "configuration_version"
    t.string   "environment"
    t.string   "transaction_uuid"
  end

  add_index "reports", ["node_id"], :name => "index_reports_on_node_id"
  add_index "reports", ["time", "node_id", "status"], :name => "index_reports_on_time_and_node_id_and_status"

  create_table "resource_events", :force => true do |t|
    t.integer  "resource_status_id",                :null => false
    t.text     "previous_value",     :limit => 255		unless postgres
    t.text     "previous_value"					if postgres
    t.text     "desired_value",      :limit => 255		unless postgres
    t.text     "desired_value"					if postgres
    t.text     "message",            :limit => 255		unless postgres
    t.text     "message"					if postgres
    t.string   "name"
    t.string   "property"
    t.string   "status"
    t.datetime "time"
    t.text     "historical_value",   :limit => 255		unless postgres
    t.text     "historical_value"				if postgres
    t.boolean  "audited"
  end

  add_index "resource_events", ["resource_status_id"], :name => "index_resource_events_on_resource_status_id"

  create_table "resource_statuses", :force => true do |t|
    t.integer  "report_id",                                                       :null => false
    t.string   "resource_type"
    t.text     "title",             :limit => 255		unless postgres
    t.text     "title"						if postgres
    t.decimal  "evaluation_time",                  :precision => 12, :scale => 6
    t.text     "file",              :limit => 255		unless postgres
    t.text     "file"						if postgres
    t.integer  "line"
    t.text     "tags",              :limit => 255		unless postgres
    t.text     "tags"						if postgres
    t.datetime "time"
    t.integer  "change_count"
    t.integer  "out_of_sync_count"
    t.boolean  "skipped"
    t.boolean  "failed"
    t.string   "status"
    t.text     "containment_path"
  end

  add_index "resource_statuses", ["report_id"], :name => "index_resource_statuses_on_report_id"

  create_table "timeline_events", :force => true do |t|
    t.string   "event_type"
    t.string   "subject_type"
    t.string   "actor_type"
    t.string   "secondary_subject_type"
    t.integer  "subject_id"
    t.integer  "actor_id"
    t.integer  "secondary_subject_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "timeline_events", ["secondary_subject_id", "secondary_subject_type"], :name => "index_timeline_events_secondary"
  add_index "timeline_events", ["subject_id", "subject_type"], :name => "index_timeline_events_primary"

end
