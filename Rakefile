#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
RAKE_ROOT = File.dirname(__FILE__)
require 'rake'

["rake/testtask","rdoc/task","thread"].each do |dependency|
  begin
    require dependency
  rescue LoadError => e
    puts "Could not load #{dependency}. Some rake tasks may not be available without #{dependency}."
    puts "The load error generated the following message: #{e.message}"
  end
end

begin
  load File.join(RAKE_ROOT, 'ext', 'packaging', 'packaging.rake')
rescue LoadError
end

build_defs_file = 'ext/build_defaults.yaml'
if File.exist?(build_defs_file)
  begin
    require 'yaml'
    @build_defaults ||= YAML.load_file(build_defs_file)
  rescue Exception => e
    STDERR.puts "Unable to load yaml from #{build_defs_file}:"
    STDERR.puts e
  end
  @packaging_url  = @build_defaults['packaging_url']
  @packaging_repo = @build_defaults['packaging_repo']
  raise "Could not find packaging url in #{build_defs_file}" if @packaging_url.nil?
  raise "Could not find packaging repo in #{build_defs_file}" if @packaging_repo.nil?

  namespace :package do
    desc "Bootstrap packaging automation, e.g. clone into packaging repo"
    task :bootstrap do
      if File.exist?("ext/#{@packaging_repo}")
        puts "It looks like you already have ext/#{@packaging_repo}. If you don't like it, blow it away with package:implode."
      else
        cd 'ext' do
          %x{git clone #{@packaging_url}}
        end
      end
    end
    desc "Remove all cloned packaging automation"
    task :implode do
      rm_rf "ext/#{@packaging_repo}"
    end
  end
end

include Rake::DSL

# We have packaging tasks that we want to be able to run without
# all of the gems installed. Rails, rather than Bundler, is a good
# proxy to whether we have a skeleton gemset for packaging or a full
# operational gemset.
begin
  require 'rails'
  require(File.join(File.dirname(__FILE__), 'config', 'boot'))
  require File.expand_path('../config/application', __FILE__)

  PuppetDashboard::Application.load_tasks
rescue LoadError
  STDERR.puts "Warning: Rails rake tasks currently unavailable because we can't find the 'rails' gem"
end
