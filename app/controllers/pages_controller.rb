class PagesController < ApplicationController
  def home
    @statuses = Status.by_interval(:limit => 30)
    @reports = Report.all(:limit => 30)
    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.by_report_date.all(:limit => 10)
  end
end
