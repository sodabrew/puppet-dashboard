desc "Install the Puppet Dashboard"
task :install do
  puts "Please see the README.markdown file for installation instructions."
end

desc "Update the Puppet Dashboard"
task :update => ['db:migrate']
