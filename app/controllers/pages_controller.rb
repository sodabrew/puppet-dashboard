class PagesController < ApplicationController
  def home
    @nodes = Node.unhidden

    @currently_failing_nodes   = @nodes.by_currentness_and_successfulness(true, false)
    @unreported_nodes          = @nodes.unreported
    @no_longer_reporting_nodes = @nodes.no_longer_reporting
    @recently_reported_nodes   = @nodes.reported.by_report_date.all(:limit => 10)

    @unresponsive_nodes       = @nodes.unresponsive
    @failed_nodes             = @nodes.failed
    @pending_nodes            = @nodes.pending
    @changed_nodes            = @nodes.changed
    @unchanged_nodes          = @nodes.unchanged
  end

  def release_notes
  end
end
