require 'spec_helper'

describe "/reports/show.html.haml", :type => :view do
  include ReportsHelper

  describe "successful render" do
    before :each do
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      @report = Report.create_from_yaml(report_yaml)
      render
    end

    # <span class='changed status'>
    # <img alt="Changed" src="/images/icons/changed.png" title="Changed over 2 years ago" />
    it { rendered.should have_tag('.status img', :with => { :src => '/images/icons/changed.png' }) }
    it { rendered.should have_tag('a', :with => { :href => node_path(@report.node) }) }
  end
end
