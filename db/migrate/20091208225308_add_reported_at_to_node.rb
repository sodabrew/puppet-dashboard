class AddReportedAtToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :reported_at, :timestamp

    begin
      STDOUT.puts "-- migrate Node data"
      ms = Benchmark.ms do
        nodes = Node.all.select{|n| n.last_report.respond_to?(:report)}
        pbar = ProgressBar.new("   ->", nodes.size)
        ms = Benchmark.ms do
          nodes.each{|n| n.update_attribute(:reported_at, n.last_report.report.time); pbar.inc}
        pbar.finish
        end
      end
    rescue => e
      STDERR.puts "   -> Error: " << e.message
    end
  end

  def self.down
    remove_column :nodes, :reported_at
  end
end
