$LOAD_PATH.push File.dirname(__FILE__)

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha'
require 'spec/autorun'
require 'spec/rails'
require 'shoulda'
require 'factory_girl'
require 'factory_girl/syntax/generate'
require 'spec/factories'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.prepend_before :each do
    verbosity = $VERBOSE
    $VERBOSE = nil
    SETTINGS = SettingsReader.default_settings
    $VERBOSE = verbosity
  end
end
