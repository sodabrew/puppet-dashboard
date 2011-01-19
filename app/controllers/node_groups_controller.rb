class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_unless_using_external_node_classification
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex

  def diff
    @node_group = NodeGroup.find(params[:id])

    @nodes_without_latest_inspect_reports = []
    @nodes_without_baselines = []
    @nodes_without_differences = []
    @nodes_with_differences = []
    @node_group.all_nodes.each do |node|
      @nodes_without_latest_inspect_reports << node and next unless node.last_inspect_report
      @nodes_without_baselines << node and next unless node.baseline_report

      report_diff = node.baseline_report.diff(node.last_inspect_report)
      resource_statuses = Report.divide_diff_into_pass_and_fail(report_diff)

      if resource_statuses[:failure].empty?
        @nodes_without_differences << node
      else
        @nodes_with_differences << {
          :baseline_report     => node.baseline_report,
          :last_inspect_report => node.last_inspect_report,
          :report_diff         => report_diff,
          :resource_statuses   => resource_statuses,
        }
      end
    end
  end
end
