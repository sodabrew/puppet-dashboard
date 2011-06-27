class CreateDelayedJobFailures < ActiveRecord::Migration
  def self.up
    create_table :delayed_job_failures do |t|
      t.string      :summary, :limit => 255
      t.text        :details
      t.boolean     :read, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :delayed_job_failures
  end
end
