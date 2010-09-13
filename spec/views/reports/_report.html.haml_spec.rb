require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/_report.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      assigns[:report] = @report = Report.generate!
      template.stubs(:resource => @report)
      render :locals => {:report => @report}
    end

    specify { response.should be_success }
  end
end
