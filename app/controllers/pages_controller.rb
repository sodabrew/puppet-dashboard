class PagesController < ApplicationController
  def home
    @statuses = Status.by_interval(:limit => 30)
    @reports = Report.all(:limit => 20, :order => 'time ASC')
    @failed_nodes = Node.failed
    @unreported_nodes = Node.unreported
    @no_longer_reporting_nodes = Node.no_longer_reporting

    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.by_report_date.all(:limit => 10)
  end
end
