class PagesController < ApplicationController
  def home
    @currently_failing_nodes = Node.by_currentness_and_successfulness(true, false).unhidden
    @unreported_nodes = Node.unreported.unhidden
    @no_longer_reporting_nodes = Node.no_longer_reporting.unhidden
    @recently_reported_nodes = Node.reported.by_report_date.unhidden.all(:limit => 10)

    @unhidden_nodes = Node.unhidden
  end

  def release_notes
  end
end
