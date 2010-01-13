namespace :reports do
  desc 'summarize reports'
  task :summarize => :environment do
    if ENV['lastreport']
      if ENV['range']
        range = ENV['range']

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
          esec = range.to_i * units[unit].to_i
        else
          puts 'I don\'t know that unit.'
          exit 1
        end
      else
        esec = 3540 # 59 minutes
      end

      Node.find(:all).each do |node|
        begin
          report = Report.find(:first, :conditions => "node_id = #{node.id}")

          t = report.time.to_i

          upto = Time.now.to_i - (esec + 300) # add a 5 minute buffer for time sync issues

          case upto <=> t
            when 1
              puts "#{node.name} => #{Time.at(t)}"
          end
        rescue NoMethodError
        end
      end
    end
  end
end
