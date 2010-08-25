require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/index.html.haml" do
  describe "the response"  do
    before do
      @nodes = [Node.generate!, Node.generate!]
      assigns[:reports] = @reports = @nodes.map { |node| Report.generate_for(node) }
      render
    end

    specify { response.should be_a_success }
    it { should have_tag('.report', @reports.size) }
    it { should have_tag("#report_#{@reports.first.id}") }
  end

  describe "the response with a report lacking metrics" do
    before do
      @report = Report.generate!
      @report.stubs(:metrics).returns(nil)
      assigns[:reports] = @reports = [ @report ]
      render
    end

    specify { response.should be_a_success }
    it { should have_tag('.report', 1) }
    it { should have_tag("#report_#{@report.id}") }
  end
end
