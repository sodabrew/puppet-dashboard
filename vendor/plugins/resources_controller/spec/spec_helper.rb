ENV["RAILS_ENV"] ||= "test"
require File.join(File.dirname(__FILE__), "../../../../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end