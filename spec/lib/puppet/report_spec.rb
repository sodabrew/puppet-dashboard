require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Puppet::Transaction::Report do
  extend DescribeReports

  describe "#metric_value" do
    let(:report) { report_from_yaml('puppet25/1_changed_0_failures.yml') }

    describe "when the value exists" do
      subject { total = report.metric_value(:resources, :total) }
      it { should be_present }
    end

    describe "when the value does not exist" do
      subject { report.metric_value(:resources, :missing) }
      it { should be_nil }
    end

    describe "when the key does not exist" do
      subject { report.metric_value(:missing) }
      it { should be_nil }
    end
  end

  describe_reports "#changed_statuses", :version => '0.25.x' do
    subject { report.changed_statuses }
    it { should be_nil }
  end

  describe_reports "#changed_statuses", :version => '2.6.x' do
    subject { report.changed_statuses }
    it { subject.size.should == report.changed_resources }
    it { should be_a_kind_of(Hash) }

    it "contains Puppet::Resource::Status objects" do
      should be_all{ |name, value| value.is_a? Puppet::Resource::Status }
    end
  end

  describe_reports "#changed_resources" do
    subject { report.changed_resources }
    it { should == info[:changed] }
  end

  describe_reports "#changed?" do
    subject { report.changed? }
    it { should == info[:changed] > 0}
  end

  describe_reports "#failed_resources" do
    subject { report.failed_resources }
    it { should == info[:failed] }
  end

  describe_reports "#failed?" do
    subject { report.failed? }
    it { should == info[:failed] > 0 }
  end

  describe_reports "#total_resources" do
    subject { report.total_resources }
    it { should == info[:total] }
  end

  describe_reports ".total_time" do
    subject { report.total_time }
    it { should == info[:total_time] }
  end

  describe_reports ".time" do
    subject { report.time }
    it { should == info[:time] }
  end

  describe "all reports", :shared => true do
    it { should be_a_kind_of(ReportExtensions) }
    it { should respond_to(:metrics) }
    it { should respond_to(:logs) }
    it { should respond_to(:host) }
    it { should respond_to(:time) }

    describe "#metrics" do
      subject { report.metrics }
      it { should be_a_kind_of Hash }
    end

    describe "#[]" do
      subject { report.metrics["time"] }

      it "returns a Metric object" do
        should be_a_kind_of Puppet::Util::Metric
      end
    end
  end

  describe "from Puppet 0.25.x" do
    let :report do
      Report.new(:report => File.read(Rails.root.join('spec', 'fixtures', 'sample_report.yml'))).report
    end

    subject { report }

    it("version should be 0.25.x") { subject.version.should == "0.25.x" }

    it_should_behave_like "all reports"
  end

  describe "from Puppet 2.6.x" do
    let :report do
      Report.new(:report => File.read(Rails.root.join('spec', 'fixtures', 'sample_report_2_6_0.yml'))).report
    end

    subject { report }

    it { should be_a_kind_of(ReportExtensions) }

    it("version should be 2.6.x") { subject.version.should == "2.6.x" }

    it_should_behave_like "all reports"

    it { should respond_to(:external_times) }
    it { should respond_to(:resource_statuses) }
  end

  def report_from_yaml(path)
    report_root = Rails.root.join('spec', 'fixtures', 'reports')
    report_file = report_root.join(path)
    raise "No such file #{report_file}" unless File.exists?(report_file)
    report_yaml = File.read(report_file)
    Report.new(:report => report_yaml).report
  end

end
