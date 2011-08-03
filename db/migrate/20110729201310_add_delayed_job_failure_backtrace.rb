class AddDelayedJobFailureBacktrace < ActiveRecord::Migration
  def self.up
    add_column :delayed_job_failures, :backtrace, :text
  end

  def self.down
    remove_column :delayed_job_failures, :backtrace
  end
end
