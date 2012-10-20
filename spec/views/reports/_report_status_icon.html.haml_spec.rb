require 'spec_helper'

describe "/reports/_report_status_icon.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      assigns[:report] = @report = Report.generate!(:status => "changed")
      view.stubs(:resource => @report)
      render :locals => {:report => @report}
    end

    specify { rendered.should be_success }
    it { should have_tag('img[src=?]', /.+changed.+/) }
  end
end
