class PagesController < ApplicationController
  def home
    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.by_report_date.all(:limit => 10)
  end
end
