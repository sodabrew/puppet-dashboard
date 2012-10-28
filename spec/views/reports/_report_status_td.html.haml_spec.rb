require 'spec_helper'

describe "/reports/_report_status_td.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      assigns[:report] = @report = Report.generate!(:status => "changed")
      render :partial => 'reports/report_status_td', :locals => { :report => @report }
    end

    it { rendered.should have_tag('td.status.changed img', :with => { :src => '/images/icons/changed.png' }) }
  end
end
