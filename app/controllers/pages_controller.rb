class PagesController < ApplicationController
  def home
    @nodes = Node.unhidden

    @currently_failing_nodes = @nodes.by_currentness_and_successfulness(true, false)
    @unreported_nodes = @nodes.unreported
    @no_longer_reporting_nodes = @nodes.no_longer_reporting
    @recently_reported_nodes = @nodes.reported.by_report_date.all(:limit => 10)

    @unresponsive_nodes = @nodes.current(false)
    @current_nodes      = @nodes.current(true)
    @failed_nodes       = @current_nodes.successful(false)
    @successful_nodes   = @current_nodes.successful(true)
    @pending_nodes      = @successful_nodes.pending(true)
    @compliant_nodes    = @successful_nodes.pending(false)
  end

  def release_notes
  end
end
