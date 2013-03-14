require 'spec_helper'

describe "/reports/index.html.haml" do
  describe "the response"  do
    before :each do
      @nodes = [Node.generate!, Node.generate!]
      assigns[:reports] = @reports = @nodes.map { |node| Report.generate!(:host => node.name) }.paginate
      render
    end

    it { rendered.should have_tag('.report', :count => @reports.size) }
    it { rendered.should have_tag("#report_#{@reports.first.id}") }
  end

  describe "the response with a report lacking metrics" do
    before :each do
      @report = Report.generate!
      assigns[:reports] = @reports = [ @report ].paginate
      render
    end

    it { rendered.should have_tag('.report', :count => 1) }
    it { rendered.should have_tag("#report_#{@report.id}") }
  end
end
