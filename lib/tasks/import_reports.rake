require "#{RAILS_ROOT}/lib/progress_bar"
namespace :reports do
  DEFAULT_DIR = '/var/lib/puppet/reports/'

  desc "Import stored YAML reports from your puppet report directory (or $REPORT_DIR)"
  task :import => :environment do
    report_dir = ENV['REPORT_DIR'] || DEFAULT_DIR

    plural = lambda{|str, count| str + (count != 1 ? 's' : '')}
    reports = FileList[File.join(report_dir, '**', '*.yaml')]

    STDOUT.puts "Importing #{reports.size} #{plural['report', reports.size]} from #{report_dir} in the background"

    skipped = 0
    pbar = ProgressBar.new("Importing:", reports.size, STDOUT)
    reports.each do |report|
      success = begin
        Report.delay.create_from_yaml_file(report)
      rescue => e
        puts e
        false
      end
      skipped += 1 unless success
      pbar.inc
    end
    pbar.finish

    successes = reports.size - skipped

    STDOUT.puts "#{successes} of #{reports.size} #{plural['report', successes]} queued"
    STDOUT.puts "#{skipped} #{plural['report', skipped]} skipped" if skipped > 0
  end
end
