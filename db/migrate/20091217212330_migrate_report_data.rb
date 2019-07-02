class MigrateReportData < ActiveRecord::Migration[4.2]
  def self.up
    STDOUT.puts "-- migrate Report data"
    reports = Report.all.to_a
    if reports.size > 0
      pbar = ProgressBar.create(title: '   ->', total: reports.size)
      ms = Benchmark.ms do
        reports.each{|r| r.send(:set_attributes); r.save_without_validation; pbar.increment}
      end
    end
  ensure
    pbar and pbar.finish
  end

  def self.down
  end
end
