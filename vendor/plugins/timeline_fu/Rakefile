require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the timeline_fu plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "timeline_fu"
    s.summary = %Q{Easily build timelines, much like GitHub's news feed}
    s.email = "james@giraffesoft.ca"
    s.homepage = "http://github.com/giraffesoft/timeline_fu"
    s.description = "Easily build timelines, much like GitHub's news feed"
    s.authors = ["James Golick", "Mathieu Martin", "Francois Beausoleil"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Generate documentation for the timeline_fu plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TimelineFu'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
