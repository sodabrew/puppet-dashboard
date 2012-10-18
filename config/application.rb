require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module PuppetDashboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
  
    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W( #{RAILS_ROOT}/app/mixins )
    Dir["#{RAILS_ROOT}/vendor/gems/**"].each do |dir|
      config.autoload_paths.unshift(File.directory?(lib = "#{dir}/lib") ? lib : dir)
    end
  
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    # The user can override this in config/settings.yml.
    config.time_zone = 'UTC'
  end
end
