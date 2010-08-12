namespace :reports do
  desc 'prune old reports from the databases.  will print help if run without arguments'
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
USAGE:

  rake reports:prune upto=UPTO unit=UNIT

OPTIONS:

  upto: How far to prune as an integer
  unit: The time units.  Valid units are #{known_units}

EXAMPLE:

  rake reports:prune upto=1 unit=mon
  rake reports:prune upto=2 unit=wk
    }

    unless ENV['upto'] || ENV['unit']
      print usage
      exit 0
    end

    errors = []

    errors << "You must specify how far up you want to prune as an integer.  upto={some integer}"  \
      unless ENV['upto'] =~ /^\d+$/ && upto = ENV['upto'].to_i
    errors << "You must specify the unit of time. unit={#{known_units}}"  \
      unless unit = ENV['unit']
    errors << "I don't know that unit.  Valid units are #{known_units}"  \
      if unit && !units.has_key?(unit)

    unless errors.empty?
      errors.each { |error| puts "ERROR: " + error }
      puts usage

      exit 1
    end
    esec = Time.now.gmtime - upto * units[unit].to_i
    str_time = esec.strftime('%Y-%m-%d %H:%M:%S')

    puts "Deleting reports before #{str_time} UTC"

    num = Report.find(:all, :conditions =>
      "created_at <= '#{esec.strftime('%Y-%m-%d %H:%M:%S')}'").size

    if Report.delete_all("created_at < '#{str_time}'")
      puts "Deleted #{num} reports."
    end
  end
end
