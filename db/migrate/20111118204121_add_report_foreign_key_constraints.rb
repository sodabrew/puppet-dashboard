class AddReportForeignKeyConstraints < ActiveRecord::Migration
  def self.up
    # Can't add constraints until we clean up
    Rake::Task['reports:prune:orphaned'].invoke

    sql = Proc.new {|table, foreign_key, references|
      foreign_key ||= 'report_id'
      references  ||= 'reports'

      execute "ALTER TABLE #{table} ADD CONSTRAINT fk_#{table}_#{foreign_key} FOREIGN KEY (#{foreign_key}) REFERENCES #{references}(id) ON DELETE CASCADE;"
    }

    sql.call('reports', 'node_id', 'nodes')
    sql.call('resource_events', 'resource_status_id', 'resource_statuses')
    sql.call('resource_statuses')
    sql.call('report_logs')
    sql.call('metrics')
  end

  def self.down
    {
      :reports           => 'node_id',
      :resource_events   => 'resource_status_id',
      :resource_statuses => 'report_id',
      :report_logs       => 'report_id',
      :metrics           => 'report_id',
    }.each do |table, column_name|
      execute("ALTER TABLE #{table} DROP FOREIGN KEY fk_#{table}_#{column_name}")
    end
  end
end
