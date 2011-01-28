class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_unless_using_external_node_classification
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex

  def diff
    @node_group = NodeGroup.find(params[:id])
    unless params[:baseline_type] == "self"
      @baseline = Node.find_by_name!(params[:baseline_host]).baseline_report
      raise ActiveRecord::RecordNotFound.new("Node #{params[:baseline_host]} does not have a baseline report set") unless @baseline
    end

    @nodes_without_latest_inspect_reports = []
    @nodes_without_baselines = []
    @nodes_without_differences = []
    @nodes_with_differences = []
    @node_group.all_nodes.sort_by(&:name).each do |node|
      baseline = @baseline || node.baseline_report
      @nodes_without_latest_inspect_reports << node and next unless node.last_inspect_report
      @nodes_without_baselines << node and next unless baseline

      report_diff = baseline.diff(node.last_inspect_report)
      resource_statuses = Report.divide_diff_into_pass_and_fail(report_diff)

      if resource_statuses[:failure].empty?
        @nodes_without_differences << node
      else
        @nodes_with_differences << {
          :baseline_report     => baseline,
          :last_inspect_report => node.last_inspect_report,
          :report_diff         => report_diff,
          :resource_statuses   => resource_statuses,
        }
      end
    end
  end
end
