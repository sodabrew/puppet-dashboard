class CreateDelayedJobs < ActiveRecord::Migration
  def self.up
    create_table :delayed_jobs, :force => true do |table|
      # Allows some jobs to jump to the front of the queue
      table.integer  :priority, :default => 0
      # Provides for retries, but still fail eventually.
      table.integer  :attempts, :default => 0
      # YAML-encoded string of the object that will do work
      table.text     :handler,  :limit => 16.megabytes
      # reason for last failure (See Note below)
      table.text     :last_error
      # When to run. Could be Time.zone.now for immediately, or sometime in
      # the future.
      table.datetime :run_at
      # Set when a client is working on this object
      table.datetime :locked_at
      # Set when all retries have failed (actually, by default, the record is
      # deleted instead)
      table.datetime :failed_at
      # Who is working on this object (if locked)
      table.string   :locked_by
      table.timestamps
    end

    add_index :delayed_jobs, [:priority, :run_at], :name => 'delayed_jobs_priority'

    STDERR.puts <<EOT
========================================================================
You MUST run at least one `delayed_job` worker on your system, so that
background jobs are processed.  Without this various parts of dashboard,
especially things like report import, will not work.

Please see `README.markdown` for details of how to run the workers, or
use one of:

] rake RAILS_ENV=production jobs:work
] ./script/delayed_job -p dashboard -n $CPUS -m start
========================================================================
EOT
  end

  def self.down
    drop_table :delayed_jobs
  end
end
