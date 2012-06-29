require 'fileutils'
namespace :cron do
  desc 'Install monthly cron job to automatically prune old reports from the databases.'
  task :cleanup do
    cron_path      = '/etc/cron.monthly'
    dashboard_path = '/usr/share/puppet-dashboard/examples'
    cron_script    = 'puppet-dashboard.cleanup_reports.cron'

    begin
      ln_sf("#{dashboard_path}/#{cron_script}", "#{cron_path}/#{cron_script}")
    rescue
      puts "\n\nError: Could not create symlink #{cron_path}/#{cron_script}\n"
      puts "Are you root?\n"
    end
  end
end
