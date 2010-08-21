require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/_report_status_td.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before do
      assigns[:report] = @report = Report.generate!
      render :locals => {:report => @report}
    end

    specify { response.should be_success }
    it { should have_tag('td.status.success img[src=?]', /.+success.+/) }
  end
end
