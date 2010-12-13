require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/show.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      assigns[:report] = @report = Report.create_from_yaml(report_yaml)
      render
    end

    specify { response.should be_success }
    it { should have_tag('.status img[src=?]', /.+changed.+/) }
    it { should have_tag('a[href=?]', node_path(@report.node)) }
  end
end
