# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha'
require 'spec/autorun'
require 'spec/rails'
require 'shoulda'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
