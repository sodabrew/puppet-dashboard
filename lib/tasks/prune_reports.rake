require "#{Rails.root}/lib/progress_bar"

namespace :reports do
  desc 'Prune old reports from the databases, will print help if run without arguments'
  task :prune => :environment do
    units = {
      'min' => '60',
      'hr' => '3600',
      'day' => '86400',
      'wk' => '604800',
      'mon' => '2592000',
      'yr' => '31536000'
    }
    known_units = units.keys.join(',')

    statuses = [
      'changed',
      'unchanged',
      'pending',
      'failed'
    ]
    known_statuses = statuses.join(',')

    conditions = {
      'is' => '=',
      'not' => '!='
    }
    known_conditions = conditions.keys.join(',')

    usage = %{
EXAMPLE:
  # Prune records upto 1 month old:
  rake reports:prune upto=1 unit=mon

  # Prune records upto 1 month old and with status 'unchanged'
  rake reports:prune upto=1 unit=mon condition=is status=unchanged

UNITS:
  Valid units of time are: #{known_units}

STATUS & CONDITION:
  Valid status values are: #{known_statuses}
  Valid condition values are: #{known_conditions}
    }.strip

    unless ENV['upto'] || ENV['unit']
      $stderr.puts usage
      exit 1
    end

    errors = []

    if ENV['upto'] =~ /^\d+$/
      upto = ENV['upto'].to_i
    else
      errors << "You must specify how far up you want to prune as an integer, e.g.: upto={some integer}" \
    end

    if unit = ENV['unit']
      unless units.has_key?(unit)
        errors << "I don't know that unit. Valid units are: #{known_units}" \
      end
    else
      errors << "You must specify the unit of time, .e.g.: unit={#{known_units}}" \
    end

    if ( ENV['status'] && ! ENV['condition'] ) || ( ENV['condition'] && ! ENV['status'] )
      errors << "You must specify status AND condition!"\
    end

    if status = ENV['status']
      unless statuses.include?(status)
        errors << "I don't know that status. Valid statuses are: #{known_statuses}"\
      end
    else
      status = ""
    end

    if condition = ENV['condition']
      unless conditions.has_key?(condition)
        errors << "I don't know that condition. Valid conditionss are: #{known_conditions}"\
      end
    else
      condition = "!="
    end

    if errors.present?
      $stderr.puts errors.map { |error| "ERROR: #{error}" }
      $stderr.puts
      $stderr.puts usage
      exit 1
    end

    if condition != "!="
      condition = conditions[condition]
    end

    # Thin query for nodes with reports that may be pruned.
    # By selecting the 'id' column only, it does not eager load all of the
    # nodes and definitely not all of the reports, making this much faster.
    cutoff = Time.now.gmtime - (upto * units[unit].to_i)
    affected_nodes = Node.select('DISTINCT nodes.id') \
                         .joins('LEFT OUTER JOIN reports ON reports.node_id = nodes.id') \
                         .where("reports.time < \"#{cutoff}\" and reports.status #{condition} \"#{status}\"")
    deletion_count = affected_nodes.count
    puts "#{Time.now.to_s(:db)}: Deleting reports before #{cutoff} and with report status #{condition} \"#{status}\" for #{deletion_count} nodes"

    pbar = ProgressBar.new('Deleting', deletion_count, STDOUT)
    deleted_count = 0

    begin
      affected_nodes.each do |node|
        node.reload # Become a complete object (the query above returns shalow objects with 'id' only)
        deleted_count += node.prune_reports(cutoff, condition, status)
        pbar.inc
      end
    rescue SignalException
      # Trap signals (e.g. CTRL-C) so that we can show how far we got
    end

    pbar.finish
    puts
    puts "#{Time.now.to_s(:db)}: Deleted #{deleted_count} reports."
  end

  namespace :prune do
    desc 'Delete orphaned records whose report has already been deleted'
    task :orphaned => :environment do
      report_dependent_deletion = 'report_id not in (select id from reports)'

      orphaned_tables = ActiveSupport::OrderedHash[
        Metric,         report_dependent_deletion,
        ReportLog,      report_dependent_deletion,
        ResourceStatus, report_dependent_deletion,
        ResourceEvent, 'resource_status_id not in (select id from resource_statuses)'
      ]

      puts "Going to delete orphaned records from #{orphaned_tables.keys.map(&:table_name).join(', ')}\n"

      orphaned_tables.each do |model, deletion_where_clause|
        puts "Preparing to delete from #{model.table_name}"
        start_time     = Time.now
        deletion_count = model.count(:conditions => deletion_where_clause)

        puts "#{start_time.to_s(:db)}: Deleting #{deletion_count} orphaned records from #{model.table_name}"
        pbar = ProgressBar.new('Deleting', deletion_count, STDOUT)

        # Deleting a very large group of records in MySQL can be very slow with no feedback
        # Breaking the deletion up into blocks turns out to be overall faster
        # and allows for progress feedback
        DELETION_BATCH_SIZE = 1000
        while deletion_count > 0
          ActiveRecord::Base.connection.execute(
            "delete from #{model.table_name} where #{deletion_where_clause} limit #{DELETION_BATCH_SIZE}"
          )
          pbar.inc(DELETION_BATCH_SIZE)
          deletion_count -= DELETION_BATCH_SIZE
        end

        pbar.finish
        puts
      end
    end
  end
end
