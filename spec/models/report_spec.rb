require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  REPORTS_META = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'meta.yml')).with_indifferent_access

  describe "#report" do
    include DescribeReports

    describe "on creation" do
      before :each do
        @now = Time.now
        Time.stubs(:now).returns(@now)
        @node = Node.generate
        @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/sample_report.yml"))
        @report_data = YAML.load(@report_yaml).extend(ReportExtensions)
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

      it "sets status correctly based on whether the report contains failures" do
        report = report_model_from_yaml('failure.yml')
        report.save!
        Report.find(report.id).status.should == 'failed'
      end

      it "should properly create a valid report" do
        report = report_model_from_yaml('success.yml')
        report.save!
        Report.find(report.id).status.should == 'unchanged'
      end

      it "should consider a blank report to be invalid" do
        Report.create(:report => '').should_not be_valid
      end

      it "should consider a report in incorrect format to be invalid" do
        Report.create(:report => 'foo bar baz bad data invalid').should_not be_valid
      end

      it "should consider a report in correct format to be valid" do
        report_from_yaml.should be_valid
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
      before :each do
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

    describe "when retrieving report data" do
      it "should get the total time for 0.25.x reports" do
        report = report_from_yaml("puppet25/1_changed_0_failures.yml")
        report.total_time.should == "0.25"
      end

      it "should get the total time for 2.6.x reports" do
        report = report_from_yaml("puppet26/0_changed_0_failures.yml")
        report.total_time.should == "0.11"
      end

      it "should get the config retrieval time for 0.25.x reports" do
        report = report_from_yaml("puppet25/1_changed_0_failures.yml")
        report.config_retrieval_time.should == "0.19"
      end

      it "should get the config retrieval time for 2.6.x reports" do
        report = report_from_yaml("puppet26/0_changed_0_failures.yml")
        report.config_retrieval_time.should == "0.11"
      end
    end
  end

  describe "when destroying the most recent report for a node" do
    before :each do
      @node = Node.generate
      @report = Report.generate_for(@node, 1.week.ago.to_date, 'unchanged')
    end

    it "should set the node's most recent report to what is now the most recent report" do
      @newer_report = Report.generate_for(@node, Time.now, 'failed')
      @node.last_report.should == @newer_report
      @node.reported_at.should == @newer_report.time
      @node.status.should == @newer_report.status

      @newer_report.destroy

      @node.last_report.should == @report
      @node.reported_at.should == @report.time
      @node.status.should == @report.status
    end

    it "should clear the node's most recent report if there are no other reports" do
      @report.destroy

      @node.last_report.should == nil
      @node.reported_at.should == nil
      @node.status.should == 'unchanged'
    end
  end

  describe "when diffing inspection reports" do
    before :each do
      @report_yaml = <<-'HEREDOC'
--- !ruby/object:Puppet::Transaction::Report
  host: mattmac.puppetlabs.lan
  kind: inspect
  logs: []
  metrics: {}
  resource_statuses: 
    "File[/tmp/foo]": !ruby/object:Puppet::Resource::Status
      events: 
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: &id001 /Users/matthewrobinson/work/puppet/test_data/genreportm/manifests/site.pp
          line: 5
          message: inspected value is :file
          previous_value: !ruby/sym file
          property: ensure
          resource: "File[/tmp/foo]"
          status: audit
          tags: 
            - &id002 file
            - &id003 class
          time: 2010-12-03 12:18:40.039434 -08:00
          version: 1291407517
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: *id001
          line: 5
          message: "inspected value is \"{md5}foo\""
          previous_value: "{md5}foo"
          property: content
          resource: "File[/tmp/foo]"
          status: audit
          tags: 
            - *id002
            - *id003
          time: 2010-12-03 12:08:59.061376 -08:00
          version: 1291406846
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: *id001
          line: 5
          message: inspected value is nil
          property: target
          resource: "File[/tmp/foo]"
          status: audit
          tags: 
            - *id002
            - *id003
          time: 2010-12-03 12:08:59.061413 -08:00
          version: 1291406846
HEREDOC
      @report_yaml2 = <<-'HEREDOC'
--- !ruby/object:Puppet::Transaction::Report
  host: mattmac.puppetlabs.lan
  kind: inspect
  logs: []
  metrics: {}
  resource_statuses: 
    "File[/tmp/foo]": !ruby/object:Puppet::Resource::Status
      events: 
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: &id001 /Users/matthewrobinson/work/puppet/test_data/genreportm/manifests/site.pp
          line: 5
          message: inspected value is :directory
          previous_value: !ruby/sym directory
          property: ensure
          resource: "File[/tmp/foo]"
          status: audit
          tags: 
            - &id002 file
            - &id003 class
          time: 2010-12-03 12:18:40.039434 -08:00
          version: 1291407517
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: *id001
          line: 5
          message: "inspected value is \"{md5}bar\""
          previous_value: "{md5}bar"
          property: content
          resource: "File[/tmp/foo]"
          status: audit
          tags: 
            - *id002
            - *id003
          time: 2010-12-03 12:08:59.061376 -08:00
          version: 1291406846
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: *id001
          line: 5
          message: inspected value is nil
          property: target
          resource: "File[/tmp/foo]"
          status: audit
          tags: 
            - *id002
            - *id003
          time: 2010-12-03 12:08:59.061413 -08:00
          version: 1291406846
HEREDOC
    end

    it "should produce an empty diff for the same report twice" do
      report1 = Report.create(:report => @report_yaml)
      report2 = Report.create(:report => @report_yaml)
      report1.diff(report2).should == {}
    end

    it "should show diff for the different reports" do
      report1 = Report.create(:report => @report_yaml)
      report2 = Report.create(:report => @report_yaml2)
      report1.diff(report2).should == {
        ['File[/tmp/foo]', :ensure] => [:file, :directory],
        ['File[/tmp/foo]', :content] => ["{md5}foo", "{md5}bar"]
      }
    end
  end
end
