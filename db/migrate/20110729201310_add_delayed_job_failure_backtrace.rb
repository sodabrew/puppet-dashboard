class AddDelayedJobFailureBacktrace < ActiveRecord::Migration[4.2]
  def self.up
    add_column :delayed_job_failures, :backtrace, :text
  end

  def self.down
    remove_column :delayed_job_failures, :backtrace
  end
end
