require 'ardes/resources_controller'
ActionController::Base.extend Ardes::ResourcesController

require 'ardes/active_record/saved'
ActiveRecord::Base.send :include, Ardes::ActiveRecord::Saved