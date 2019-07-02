namespace :reports do
  desc 'Performs updates to the reports that are specific to dashboard and not in the Puppet Report Format'
  task :update_report_data => :environment do
    report_count = Report.count

    pbar = ProgressBar.create(title: 'Updating', total: report_count)

    offset = 0

    # Doing records in groups of 1_000 since finding all with millions at once takes forever and eats memory
    while offset < Report.count
      Report.all.limit(1_000).offset(offset).order('time desc').to_a.each do |report|
        report.munge
        report.save!

        pbar.increment
        offset += 1
      end
    end

    pbar.finish

  end
end

