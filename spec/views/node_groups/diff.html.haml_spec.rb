require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/diff.html.haml" do
  describe "successful render" do
    before :each do
      assigns[:node_group] = node_group = NodeGroup.generate!

      node = Node.generate!

      node_group.nodes << node

      report1 = Factory.create(:baseline_inspect_report, :node => node)
      report2 = Factory.create(:inspect_report,          :node => node)

      report1.resource_statuses.create!(
        :events_attributes => [{
          :property        => "shape",
          :previous_value  => "hypocube"
        }]
      )

      assigns[:nodes_without_latest_inspect_reports] = []
      assigns[:nodes_without_baselines]              = []
      assigns[:nodes_without_differences]            = []

      diff = report1.diff(report2)

      assigns[:nodes_with_differences] = [{
        :baseline_report     => report1,
        :last_inspect_report => report2,
        :report_diff         => diff,
        :resource_statuses   => Report.divide_diff_into_pass_and_fail(diff),
      }]
      render
    end

    specify { response.should be_a_success }

    it "should have only one expand-all link" do
      assert_select "h2", "Nodes with difference from baseline"
      assert_select "a.expand-all", 1
    end
  end
end
