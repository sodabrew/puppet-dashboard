require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  REPORTS_META = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'meta.yml')).with_indifferent_access

  describe "#report" do
    include DescribeReports

    describe "on creation" do
      before do
        @now = Time.now
        Time.stubs(:now).returns(@now)
        @node = Node.generate
        @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/sample_report.yml"))
        @report_data = YAML.load(@report_yaml).extend(ReportExtensions).extend(ReportExtensions)
      end

      it "handles greater than 64k of report text without truncating" do
        # can actually handle up to 16mb but that test is really slow
        report = report_from_yaml
        file_size = 65 * 1024
        report.report.logs.first.instance_variable_set(:@message, "*" * file_size)
        original_report_length = report.report.logs.first.message.length
        report.save!
        report.reload
        report.report.logs.first.message.length.should == original_report_length
      end

      it "sets success correctly based on whether the report contains failures" do
        report = report_model_from_yaml('failure.yml')
        report.save!
        Report.find(report.id).should_not be_success
      end

      it "is not created if a report for the same host exists with the same time" do

        Report.create(:report => @report_yaml)
        lambda {
          Report.create(:report => @report_yaml)
        }.should_not change(Report, :count)
      end

      it "assigns a node by host if it exists" do
        node = Node.generate(:name => @report_data.host)
        Report.create(:report => @report_yaml).node.should == node
      end

      it "creates a node by host if none exists" do
        lambda {
          Report.create(:report => @report_yaml)
        }.should change { Node.count(:conditions => {:name => @report_data.host}) }.by(1)
      end

      it "updates the node's reported_at timestamp" do
        node = Node.generate(:name => @report_data.host)
        report = Report.create(:report => @report_yaml)
        node.reload
        node.reported_at.should be_close(@report_data.time.in_time_zone, 1.second)
      end

      it "does not create a timeline event for the node" do
        pending "FIXME figure out why Report#update_node can't save an object with #update_without_callbacks any more"
        node = Node.generate(:name => @report_data.host)
        lambda {
          Report.create(:report => @report_yaml)
          node.reload
        }.should_not change(TimelineEvent, :count)
      end
    end

    describe "deserializing the report" do
      before do
        @yaml_file = File.join RAILS_ROOT, "spec", "fixtures", "sample_report.yml"
        @loading_yaml = proc { YAML.load_file(@yaml_file) }
      end

      it "should be able to parse the report" do
        @loading_yaml.should_not raise_error
      end

      it "should return a puppet report object" do
        @loading_yaml.call.should be_a_kind_of Puppet::Transaction::Report
      end

      it "should deserialize into the correct object tyoe" do
        report = Report.new(:report => File.read(@yaml_file))
        report.report.should be_a_kind_of(Puppet::Transaction::Report)
      end
    end

    def report_from_yaml(path="puppet25/1_changed_0_failures.yml" )
      report_root = Rails.root.join('spec', 'fixtures', 'reports')
      report_file = report_root.join(path)
      raise "No such file #{report_file}" unless File.exists?(report_file)
      report_yaml = File.read(report_file)
      Report.new(:report => report_yaml)
    end

  end

end
