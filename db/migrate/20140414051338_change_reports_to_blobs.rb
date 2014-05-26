class ChangeReportsToBlobs < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase =~ /postgres/
      # bytea columns are unlimited
      change_column :resource_events, :message, 'bytea USING message::bytea'
      change_column :delayed_jobs, :handler, 'bytea USING handler::bytea'
      change_column :delayed_job_failures, :details, 'bytea USING details::bytea'
    else
      # Lenghts > 16MB are LONGBLOB
      change_column :resource_events, :message, :binary, :limit => 20.megabyte
      change_column :delayed_jobs, :handler, :binary, :limit => 20.megabyte
      change_column :delayed_job_failures, :details, :binary, :limit => 20.megabyte
    end
  end

  # This is not likely to work. Best not to reverse this.
  def down
    # change_column :resource_events, :message, :text
  end
end
