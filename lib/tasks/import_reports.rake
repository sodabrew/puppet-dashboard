require "#{RAILS_ROOT}/lib/progress_bar"
namespace :reports do
  DEFAULT_DIR = '/var/lib/puppet/reports/'
  DEFAULT_URL = 'http://localhost:3000/reports/upload'

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


  desc "Import by POSTing reports to dashboard in parallel"
  task :repost => :environment do
    require 'thread'
    require 'shellwords'

    report_dir = ENV['REPORT_DIR'] || DEFAULT_DIR
    url        = ENV['REPORT_URL'] || DEFAULT_URL
    concurrent = ENV['CONCURRENCY'].to_i
    concurrent = 4 unless concurrent and concurrent > 0

    plural = lambda{|str, count| str + (count != 1 ? 's' : '')}
    reports = FileList[File.join(report_dir, '**', '*.yaml')]

    STDOUT.puts "Importing #{reports.size} #{plural['report', reports.size]} from #{report_dir} (#{concurrent} at once)"

    skipped = 0
    pbar = ProgressBar.new("Importing:", reports.size, STDOUT)

    # Fill up our queue of things to do.
    work = Queue.new
    reports.each {|report| work.push report }

    # Put in place our queue of results.
    results = Queue.new

    # ...and spawn our workers to submit the request.
    workers = (1..concurrent).map do |n|
      Thread.new do
        loop do
          begin
            while item = work.pop(true) do
              cmd = "curl -sSF report=" +
                Shellwords::shellescape(item) + " " +
                Shellwords::shellescape(url)
              output = ''
              IO.popen(cmd) {|fd| output = fd.read }
              if $?.success? then
                results.push true
              else
                puts "Failed to submit #{item}: #{output}"
                results.push false
              end
              pbar.inc
            end
          rescue ThreadError => e
            # Seriously, Ruby, *this* is how you expect me to deal with
            # discovering that the queue is empty?  Am I supposed to use a racy
            # check on size, or prefer to only use a queue when I know exactly
            # how many items are going to be pushed on ahead of time?
            raise unless e.message == "queue empty"
            Thread.exit         # ...otherwise, a good exit. :)
          rescue Exception => e
            puts e
            results.push false
          end
        end
      end
    end

    # Finally, wait for all those workers to exit.
    workers.each &:join
    pbar.finish

    # Count the failed results.  This is safe because we have joined all
    # worker threads, so there should be nothing left to do.
    if work.size > 0
      raise "ERROR: still had #{work.size} items of work after threads died"
    end
    if reports.size != results.size
      raise "ERROR: missing #{reports.size - results.size} results (expected #{reports.size}, got #{results.size})"
    end

    while results.size > 0
      skipped += 1 unless results.pop(true)
    end

    successes = reports.size - skipped

    STDOUT.puts "#{successes} of #{reports.size} #{plural['report', successes]} imported"
    STDOUT.puts "#{skipped} #{plural['report', skipped]} skipped" if skipped > 0
  end
end
