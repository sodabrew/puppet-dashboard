class PagesController < ApplicationController
  def home
    @timeline_events = TimelineEvent.recent
    @nodes = Node.all
  end
end
