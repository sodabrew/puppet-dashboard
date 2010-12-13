require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/statuses/_run_failure.html.haml" do
  include ReportSupport

  describe "successful render" do
    specify do
      render
      response.should be_success
    end

    it "should display the specified number of days of data" do
      @node = Node.create!(:name => "node")

      32.times do |n|
        report_yaml = report_yaml_with(:host => "node", :time => n.days.ago)

        Report.create_from_yaml(report_yaml)
      end

      SETTINGS.stubs(:daily_run_history_length).returns(20)

      assigns[:node] = @node
      render

      response.should have_tag("tr.labels th", :count => 20)
    end
  end
end
