class ChangeReportsToBlobs < ActiveRecord::Migration
  def up
    change_column :resource_events, :message, :binary
    change_column :delayed_jobs, :handler, :binary
    change_column :delayed_job_failures, :details, :binary
  end

  # This is not likely to work. Best not to reverse this.
  def down
    # change_column :resource_events, :message, :text
  end
end
