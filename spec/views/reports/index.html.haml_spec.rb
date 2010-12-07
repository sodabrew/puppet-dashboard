require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/index.html.haml" do
  describe "the response"  do
    before :each do
      @nodes = [Node.generate!, Node.generate!]
      assigns[:reports] = @reports = @nodes.map { |node| Report.generate_for(node) }.paginate
      render
    end

    specify { response.should be_a_success }
    it { should have_tag('.report', @reports.size) }
    it { should have_tag("#report_#{@reports.first.id}") }
  end

  describe "the response with a report lacking metrics" do
    before :each do
      @report = Report.generate!
      assigns[:reports] = @reports = [ @report ].paginate
      render
    end

    specify { response.should be_a_success }
    it { should have_tag('.report', 1) }
    it { should have_tag("#report_#{@report.id}") }
  end
end
