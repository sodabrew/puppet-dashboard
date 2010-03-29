class PagesController < ApplicationController
  def home
    @statuses = Status.by_interval(:limit => 30)
    @reports = Report.all(:limit => 30, :order => 'time ASC')
    @failed_nodes = Node.failed
    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.by_report_date.all(:limit => 10)
  end
end
