namespace :timeline do
  desc 'View event timeline'
  task :view => :environment do
    TimelineEvent.recent.each do |event|
      puts "%s %s %s was %s by %s" % [
        event.created_at,
        event.subject_type,
        event.subject.name,
        event.event_type,
        event.actor_id,
      ]
    end
  end
end
