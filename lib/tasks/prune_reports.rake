namespace :reports do
  desc 'prune old reports from the databases'
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

    unless ENV['upto'] =~ /^\d+/ && ENV['unit']
      puts "You must specify how far up you want to prune.  upto={some integer}"
      puts "You must specify the unit of time. unit={#{known_units}}"
      puts "Example: 'rake reports:prune upto=1 unit=month'"
      exit 1
    end

    upto = ENV['upto']
    unit = ENV['unit']

    if units.has_key?(unit)
      esec = Time.now.gmtime - upto.to_i * units[unit].to_i
    else
      puts "I don't know that unit.  Known units are #{known_units}"
      exit 1
    end

    num = Report.find(:all, :conditions =>
      "created_at <= '#{esec.strftime('%Y-%m-%d %H:%M:%S')}'").size

    if Report.delete_all("created_at < '#{esec.strftime('%Y-%m-%d %H:%M:%S')}'")
      puts "Deleted #{num} reports."
    end
  end
end
