class PagesController < ApplicationController
  layout 'secondary_primary'
  def home
    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.all
  end
end
