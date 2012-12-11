# Puppet reports do not work with psych. Must set this prior to loading
# the Gemfile, otherwise delayed_job, etc. would use psych.
YAML::ENGINE.yamler = 'syck' if RUBY_VERSION >= '1.9'

require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
