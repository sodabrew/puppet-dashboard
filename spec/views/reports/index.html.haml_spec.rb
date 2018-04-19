require 'spec_helper'

describe "/reports/index.html.haml", :type => :view do
  describe "the response"  do
    before :each do
      @nodes = [create(:node), create(:node)]
      assigns[:reports] = @reports = @nodes.map { |node| create(:report, :host => node.name) }.paginate
      render
    end

    it { rendered.should have_tag('.report', :count => @reports.size) }
    it { rendered.should have_tag("#report_#{@reports.first.id}") }
  end

  describe "the response with a report lacking metrics" do
    before :each do
      @report = create(:report)
      assigns[:reports] = @reports = [ @report ].paginate
      render
    end

    it { rendered.should have_tag('.report', :count => 1) }
    it { rendered.should have_tag("#report_#{@report.id}") }
  end
end
