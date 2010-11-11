require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/show.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      assigns[:report] = @report = Report.generate!
      render
    end

    specify { response.should be_success }
    it { should have_tag('.status img[src=?]', /.+changed.+/) }
    it { should have_tag('a[href=?]', node_path(@report.node)) }
  end
end
