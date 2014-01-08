$LOAD_PATH.push File.dirname(__FILE__)

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha/api'
require 'rspec/autorun'
require 'rspec/rails'
require 'shoulda/matchers/integrations/rspec'
require 'factory_girl'
require 'factory_girl/syntax/generate'
require 'factories'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.mock_with :mocha
  config.prepend_before :each do
    verbosity = $VERBOSE
    $VERBOSE = nil
    SETTINGS = SettingsReader.default_settings
    $VERBOSE = verbosity
  end
end
