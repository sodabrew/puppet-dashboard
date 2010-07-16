require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  describe "#metrics" do
    it "should not fail when there are no metrics" do
      @report = Report.new
      @report.stubs(:report).returns(mock(:metrics => nil))
      lambda{@report.metrics}.should_not raise_error
    end
  end

  describe "on creation" do
    before do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @node = Node.generate
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/sample_report.yml"))
      @report_data = YAML.load @report_yaml
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
      Report.create(:report => @report_yaml)
      node.reload
      node.reported_at.should be_close(@report_data.time.in_time_zone, 1.second)
    end

    it "does not create a timeline event for the node" do
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

    it "should have the correct time" do
      @loading_yaml.call.time.to_yaml.should == "--- 2009-11-19 17:08:50.631428 -08:00\n"
    end

    it "should deserialize into the correct object tyoe" do
      report = Report.new(:report => File.read(@yaml_file))
      report.report.should be_a_kind_of(Puppet::Transaction::Report)
    end
  end

  describe "#metric_value" do
    before { @report = report_from_yaml }

    it "should return the value when present" do
      total = @report.metric_value(:resources, :total)
      total.should == @report.metrics[:resources][:total]
    end

    it "should return nil if value is not present" do
      missing = @report.metric_value(:resources, :missing)
      missing.should be_nil
    end

    it "should return nil if parent is not present" do
      missing = @report.metric_value(:missing)
      missing.should be_nil
    end
  end

  describe "#total_time" do
    subject { report_from_yaml.total_time }
    it { should == '0.25' }
  end

  describe "#total_resources" do
    subject { report_from_yaml.total_resources }
    it { should == 3 }
  end

  describe "#failed_resources" do
    subject { report_from_yaml.failed_resources }
    it { should == 0 }
  end

  describe "#changes" do
    subject { report_from_yaml.changes }
    it { should == 1 }
  end

  # describe "#changes" do
  # before do
  # @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/sample_report.yml"))
  # @report_data = YAML.load @report_yaml
  # @report = Report.create(:report => @report_yaml)
  # end

  # subject { @report }

  # it "should equal the number of changes in the report YAML" do
  # @report.
  # end

  # end

  def report_from_yaml
    report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/sample_report.yml"))
    Report.create(:report => report_yaml)
  end

end
