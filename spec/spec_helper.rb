$LOAD_PATH.push File.dirname(__FILE__)

# Start collecting data for test coverage report
require 'simplecov'
require 'simplecov-console'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
])
SimpleCov.start 'rails' do

  add_filter '/spec/'
  add_filter '/.bundle/'
  add_filter '/vendor/'
  add_group 'Tasks', "lib/tasks"
end

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha/api'
require 'rspec/rails'
require 'rspec/collection_matchers'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Uncomment to trace deprecation warnings
#ActiveSupport::Deprecation.debug = true

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.mock_with :mocha
  config.prepend_before :each do
    verbosity = $VERBOSE
    $VERBOSE = nil
    SETTINGS = SettingsReader.default_settings
    $VERBOSE = verbosity
  end
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
  config.include RSpecHtmlMatchers
end
