class AddPerformanceIndices < ActiveRecord::Migration
  def self.up
    add_index :timeline_events, [:subject_id, :subject_type], :name => 'index_timeline_events_primary'
    add_index :timeline_events, [:secondary_subject_id, :secondary_subject_type], :name => 'index_timeline_events_secondary'
    add_index :metrics, [:report_id, :category, :name], :name => 'index_metrics_multi'
    add_index :nodes, :last_apply_report_id
    add_index :parameters, [:parameterable_id, :parameterable_type, :key], :name => 'index_parameters_multi'
    add_index :delayed_jobs, [:failed_at, :run_at, :locked_at, :locked_by], :name => 'index_delayed_jobs_multi'
  end

  def self.down
    remove_index :delayed_jobs, :name => 'index_delayed_jobs_multi'
    remove_index :parameters, :name => 'index_parameters_multi'
    remove_index :nodes, :last_apply_report_id
    remove_index :metrics, :name => 'index_metrics_multi'
    remove_index :timeline_events, :name => 'index_timeline_events_secondary'
    remove_index :timeline_events, :name => 'index_timeline_events_primary'
  end
end
