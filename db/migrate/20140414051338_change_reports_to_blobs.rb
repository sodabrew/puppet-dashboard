class ChangeReportsToBlobs < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase =~ /postgres/
      change_column :resource_events, :message, 'bytea USING message::bytea'
      change_column :delayed_jobs, :handler, 'bytea USING handler::bytea'
      change_column :delayed_job_failures, :details, 'bytea USING details::bytea'
    else
      change_column :resource_events, :message, :binary
      change_column :delayed_jobs, :handler, :binary
      change_column :delayed_job_failures, :details, :binary
    end
  end

  # This is not likely to work. Best not to reverse this.
  def down
    # change_column :resource_events, :message, :text
  end
end
