class MigrateReportData < ActiveRecord::Migration
  def self.up
    STDOUT.puts "-- migrate Report data"
    pbar = ProgressBar.new("   ->", Report.count)
    ms = Benchmark.ms do
      reports = Report.all
      reports.each{|r| r.send(:set_attributes); r.save_without_validation; pbar.inc}
    end
  ensure
    pbar and pbar.finish
  end

  def self.down
  end
end
