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

    usage = %{
EXAMPLE:
  # Prune records upto 1 month old:
  rake reports:prune upto=1 unit=mon

UNITS:
  Valid units of time are: #{known_units}
    }.strip

    unless ENV['upto'] || ENV['unit']
      puts usage
      exit 0
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

    if errors.present?
      puts errors.map { |error| "ERROR: #{error}" }
      puts
      puts usage
      exit 1
    end

    cutoff = Time.now.gmtime - (upto * units[unit].to_i)
    puts "Deleting reports before #{cutoff}..."
    deleted_count = Report.delete_all(['time < ?', cutoff])
    puts "Deleted #{deleted_count} reports."
  end
end
