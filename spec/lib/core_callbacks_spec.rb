require 'spec_helper'

describe 'core' do
  before :each do
    @registry_hash = Registry.instance.instance_variable_get('@registry')
  end

  describe 'report_view_widgets' do
    describe '800_resource_statuses' do
      it "should move 'failed' resource_statuses to the start" do
        callback = @registry_hash[:core][:report_view_widgets]['800_resource_statuses']
        report = Report.create_from_yaml(File.read(File.join(Rails.root, 'spec/fixtures/reports/puppet26/report_error_on_package_service_and_files.yaml')))

        statuses = nil
        mock_renderer = stub('view_renderer')
        mock_renderer.expects(:render).with do |name, args|
          statuses = args[:statuses]
        end

        callback.call(mock_renderer, report)

        statuses.map(&:first).should == ['failed', 'unchanged']
      end
    end
  end
end
