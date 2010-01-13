namespace :reports do
  desc 'prune old reports from the databases'
  task :prune => :environment do
    if ENV['upto'] =~ /^\d+/
      upto = ENV['upto']
    else
      puts 'You must specify how far up you want to prune (as an integer).'
      exit 1
    end

    if ENV['unit']
      unit = ENV['unit']
    else
      puts 'You must specify the unit of time. (min,hr,day,wk,mon,yr)'
      exit 1
    end

    units = {
      'min' => '60',
      'hr' => '3600',
      'day' => '86400',
      'wk' => '604800',
      'mon' => '2592000',
      'yr' => '31536000'
    }

    if units.has_key?(unit)
      esec = Time.now.gmtime - upto.to_i * units[unit].to_i
    else
      puts 'I don\'t know that unit.'
      exit 1
    end

    num = Report.find(:all, :conditions =>
      "created_at <= '#{esec.strftime('%Y-%m-%d %H:%M:%S')}'").size

    if Report.delete_all("created_at < '#{esec.strftime('%Y-%m-%d %H:%M:%S')}'")
      puts "Deleted #{num} reports."
    end
  end
end
