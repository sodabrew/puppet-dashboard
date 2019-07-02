namespace :reports do
  desc 'Migrate old reports to the new reports schema in reverse chronological order'
  task :schematize => :environment do

    class OldReport < ActiveRecord::Base
    end

    old_report_count = OldReport.count

    puts
    puts "Beginning to migrate #{old_report_count} reports"
    puts "Type Ctrl+c at any time to interrupt the migration"
    puts "Restarting the migration will resume where you left off"
    puts

    pbar = ProgressBar.create(title: 'Migrating', total: old_report_count)

    while OldReport.count > 0 do
      # Doing records in groups of 10_000 since finding all with millions at once takes forever and eats memory
      OldReport.all.limit(10_000).order('time desc').to_a.each do |report|
        ActiveRecord::Base.transaction do
          Report.create_from_yaml(report.report)
          report.destroy
        end
        pbar.increment
      end
    end
    pbar.finish

  end
end

