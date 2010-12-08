require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/statuses/_run_failure.html.haml" do

  describe "successful render" do
    specify do
      render
      response.should be_success
    end

    it "should display the specified number of days of data" do
      @node = Node.create!(:name => "node")

      32.times do |n|
        report = Puppet::Transaction::Report.new
        report.stubs(:failed_resources?).returns(false)
        report.stubs(:time).returns n.days.ago
        report.stubs(:host).returns "node"

        @node.reports.create!(:report => report)
      end

      SETTINGS.stubs(:daily_run_history_length).returns(20)

      assigns[:node] = @node
      render

      response.should have_tag("tr.labels th", :count => 20)
    end
  end
end
