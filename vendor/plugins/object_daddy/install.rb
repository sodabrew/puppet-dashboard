require 'fileutils'

def readme_contents
  IO.read(File.join(File.dirname(__FILE__), 'README.markdown'))
end

rails_root = File.dirname(__FILE__) + '/../../../'

if File.directory?(rails_root + 'spec')
  unless File.directory?(rails_root + 'spec/exemplars')
    puts "Creating directory [#{rails_root + 'spec/exemplars'}]"
    FileUtils.mkdir(rails_root + 'spec/exemplars') 
  end
else
  if File.directory?(rails_root + 'test')
    unless File.directory?(rails_root + 'test/exemplars')
      puts "Creating directory [#{rails_root + 'test/exemplars'}]"
      FileUtils.mkdir(rails_root + 'test/exemplars')
    end
  else
    puts "Creating directory [#{rails_root + 'spec'}]"    
    FileUtils.mkdir(rails_root + 'spec')
    puts "Creating directory [#{rails_root + 'spec/exemplars'}]"
    FileUtils.mkdir(rails_root + 'spec/exemplars')
  end
end

puts readme_contents
