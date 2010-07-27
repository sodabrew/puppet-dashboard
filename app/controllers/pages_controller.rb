class PagesController < ApplicationController
  def home
    @statuses = Status.by_interval(:limit => 30)
    @reports = Report.all(:limit => 20, :order => 'time ASC')

    @currently_failing_nodes = Node.by_currentness_and_successfulness(true, false)
    @unreported_nodes = Node.unreported
    @no_longer_reporting_nodes = Node.no_longer_reporting

    @timeline_events = TimelineEvent.recent(10)
    @nodes = Node.by_report_date.all(:limit => 10)
  end

  def release_notes
  end
end
