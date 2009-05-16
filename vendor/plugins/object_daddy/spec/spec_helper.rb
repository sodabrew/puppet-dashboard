$:.unshift(File.dirname(__FILE__) + '/../lib/')

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def setup_rails_database
  dir = File.dirname(__FILE__)

  ENV["RAILS_ENV"] ||= "test"
  require "#{dir}/../../../../config/environment"

  db = YAML::load(IO.read("#{dir}/resources/config/database.yml"))
  ActiveRecord::Base.configurations = {'test' => db[ENV['DB'] || 'sqlite3']}
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
  ActiveRecord::Migration.verbose = false
  load "#{dir}/resources/schema"  

  require "#{dir}/../init.rb"
end
