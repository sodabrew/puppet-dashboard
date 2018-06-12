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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_06_12_210310) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_job_failures", id: :serial, force: :cascade do |t|
    t.string "summary", limit: 255
    t.binary "details"
    t.boolean "read", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "backtrace"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.binary "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue"
    t.index ["failed_at", "run_at", "locked_at", "locked_by"], name: "index_delayed_jobs_multi"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "metrics", id: :serial, force: :cascade do |t|
    t.integer "report_id", null: false
    t.string "category"
    t.string "name"
    t.decimal "value", precision: 12, scale: 6
    t.index ["report_id", "category", "name"], name: "index_metrics_multi"
    t.index ["report_id"], name: "index_metrics_on_report_id"
  end

  create_table "node_class_memberships", id: :serial, force: :cascade do |t|
    t.integer "node_id"
    t.integer "node_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["node_class_id"], name: "index_node_class_memberships_on_node_class_id"
    t.index ["node_id"], name: "index_node_class_memberships_on_node_id"
  end

  create_table "node_classes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
  end

  create_table "node_group_class_memberships", id: :serial, force: :cascade do |t|
    t.integer "node_group_id"
    t.integer "node_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["node_class_id"], name: "index_node_group_class_memberships_on_node_class_id"
    t.index ["node_group_id"], name: "index_node_group_class_memberships_on_node_group_id"
  end

  create_table "node_group_edges", id: :serial, force: :cascade do |t|
    t.integer "to_id"
    t.integer "from_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["from_id"], name: "index_node_group_edges_on_from_id"
    t.index ["to_id"], name: "index_node_group_edges_on_to_id"
  end

  create_table "node_group_memberships", id: :serial, force: :cascade do |t|
    t.integer "node_id"
    t.integer "node_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["node_group_id"], name: "index_node_group_memberships_on_node_group_id"
    t.index ["node_id"], name: "index_node_group_memberships_on_node_id"
  end

  create_table "node_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
  end

  create_table "nodes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reported_at"
    t.integer "last_apply_report_id"
    t.string "status"
    t.boolean "hidden", default: false
    t.integer "last_inspect_report_id"
    t.string "environment"
    t.index ["last_apply_report_id"], name: "index_nodes_on_last_apply_report_id"
    t.index ["name"], name: "uc_node_name", unique: true
  end

  create_table "old_reports", id: :serial, force: :cascade do |t|
    t.integer "node_id"
    t.text "report"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "host"
    t.datetime "time"
    t.string "status"
  end

  create_table "parameters", id: :serial, force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.integer "parameterable_id"
    t.string "parameterable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parameterable_id", "parameterable_type", "key"], name: "index_parameters_multi"
    t.index ["parameterable_type", "parameterable_id"], name: "index_parameters_on_parameterable_type_and_parameterable_id"
  end

  create_table "report_logs", id: :serial, force: :cascade do |t|
    t.integer "report_id", null: false
    t.string "level"
    t.text "message"
    t.text "source"
    t.text "tags"
    t.datetime "time"
    t.text "file"
    t.integer "line"
    t.index ["report_id"], name: "index_report_logs_on_report_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "node_id"
    t.string "host"
    t.datetime "time"
    t.string "status"
    t.string "kind"
    t.string "puppet_version"
    t.string "configuration_version"
    t.string "environment"
    t.string "transaction_uuid"
    t.string "catalog_uuid"
    t.string "cached_catalog_status"
    t.index ["node_id"], name: "index_reports_on_node_id"
    t.index ["time", "node_id", "status"], name: "index_reports_on_time_and_node_id_and_status"
  end

  create_table "resource_events", id: :serial, force: :cascade do |t|
    t.integer "resource_status_id", null: false
    t.text "previous_value"
    t.text "desired_value"
    t.binary "message"
    t.string "name"
    t.string "property"
    t.string "status"
    t.datetime "time"
    t.text "historical_value"
    t.boolean "audited"
    t.index ["resource_status_id"], name: "index_resource_events_on_resource_status_id"
  end

  create_table "resource_statuses", id: :serial, force: :cascade do |t|
    t.integer "report_id", null: false
    t.string "resource_type"
    t.text "title"
    t.decimal "evaluation_time", precision: 12, scale: 6
    t.text "file"
    t.integer "line"
    t.text "tags"
    t.datetime "time"
    t.integer "change_count"
    t.integer "out_of_sync_count"
    t.boolean "skipped"
    t.boolean "failed"
    t.string "status"
    t.text "containment_path"
    t.index ["report_id"], name: "index_resource_statuses_on_report_id"
  end

  create_table "timeline_events", id: :serial, force: :cascade do |t|
    t.string "event_type"
    t.string "subject_type"
    t.string "actor_type"
    t.string "secondary_subject_type"
    t.integer "subject_id"
    t.integer "actor_id"
    t.integer "secondary_subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["secondary_subject_id", "secondary_subject_type"], name: "index_timeline_events_secondary"
    t.index ["subject_id", "subject_type"], name: "index_timeline_events_primary"
  end

  add_foreign_key "metrics", "reports", name: "fk_metrics_report_id", on_delete: :cascade
  add_foreign_key "report_logs", "reports", name: "fk_report_logs_report_id", on_delete: :cascade
  add_foreign_key "reports", "nodes", name: "fk_reports_node_id", on_delete: :cascade
  add_foreign_key "resource_events", "resource_statuses", name: "fk_resource_events_resource_status_id", on_delete: :cascade
  add_foreign_key "resource_statuses", "reports", name: "fk_resource_statuses_report_id", on_delete: :cascade
end
