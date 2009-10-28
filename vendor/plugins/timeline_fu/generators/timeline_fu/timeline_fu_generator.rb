class TimelineFuGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', 
        :migration_file_name => 'create_timeline_events'
      m.template 'model.rb', 'app/models/timeline_event.rb'
    end
  end
end
