require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/_report_status_td.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      assigns[:report] = @report = Report.generate!(:status => "changed")
      render :locals => {:report => @report}
    end

    specify { response.should be_success }
    it { should have_tag('td.status.changed img[src=?]', /.+changed.+/) }
  end
end
