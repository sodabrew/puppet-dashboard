class PagesController < ApplicationController
  def home
    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.all
    render :layout => "primary_secondary"
  end
end
