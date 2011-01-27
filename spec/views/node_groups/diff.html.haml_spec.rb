require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/diff.html.haml" do
  describe "successful render" do
    before :each do
      assigns[:node_group] = node_group = NodeGroup.generate!

      node1 = Node.generate!
      node2 = Node.generate!

      node_group.nodes = [node1, node2]

      report1 = Report.generate!(
        :kind => 'inspect',
        :host => node1.name,
        :time => 2.minute.ago
      )
      report1.baseline!
      report2 = Report.generate!(
        :kind   => 'inspect',
        :host   => node1.name,
        :time   => 1.minute.ago
      )

      report1.resource_statuses.generate!(
        :events_attributes => [{
          :property        => "shape",
          :previous_value  => "cube"
        }]
      )
      report1.resource_statuses.create!(
        :events_attributes => [{
          :property        => "shape",
          :previous_value  => "hypocube"
        }]
      )

      report3 = Report.generate!(
        :kind => 'inspect',
        :host => node2.name,
        :time => 2.minute.ago
      )
      report3.baseline!
      report4 = Report.generate!(
        :kind   => 'inspect',
        :host   => node2.name,
        :time   => 1.minute.ago
      )

      report3.resource_statuses.create!(
        :events_attributes => [{
          :property        => "color",
          :previous_value  => "blue"
        }]
      )
      report4.resource_statuses.create!(
        :events_attributes => [{
          :property        => "color",
          :previous_value  => "green"
        }]
      )

      assigns[:nodes_without_latest_inspect_reports] = []
      assigns[:nodes_without_baselines] = []
      assigns[:nodes_without_differences] = []
      diff = report1.diff(report2)
      resource_statuses = Report.divide_diff_into_pass_and_fail(diff)
      assigns[:nodes_with_differences] = [{
        :baseline_report     => report1,
        :last_inspect_report => report2,
        :report_diff         => diff,
        :resource_statuses   => resource_statuses,
      }]
      render
    end
    specify { response.should be_a_success }

    it "should have only one expand-all link if there are multiple nodes with differences" do
      assert_select "h2", "Nodes with difference from baseline"
      assert_select "a.expand-all", 1
    end
  end
end
