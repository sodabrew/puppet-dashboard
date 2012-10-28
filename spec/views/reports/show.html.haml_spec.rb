require 'spec_helper'

describe "/reports/show.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      assigns[:report] = @report = Report.create_from_yaml(report_yaml)
      render
    end

    it { rendered.should have_tag('.status img', :with => { :src => /.+changed.+/ }) }
    it { rendered.should have_tag('a', :with => { :href => node_path(@report.node) }) }
  end
end
