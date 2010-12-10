require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
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

      it "should recover from errors without polluting the database" do
        Report.count.should == 0
        yaml = <<HEREDOC
--- !ruby/object:Puppet::Transaction::Report
  time: 2010-07-08 12:35:46.027576 -04:00
  host: localhost.localdomain
HEREDOC
        lambda { Report.create_from_yaml(yaml) }.should raise_exception
        Report.count.should == 0
      end

      it "sets status correctly based on whether the report contains failures" do
        report = Report.create_from_yaml(File.read(File.join(Rails.root, 'spec/fixtures/reports/failure.yml')))
        report.status.should == 'failed'
      end

      it "should properly create a valid report" do
        report = Report.create_from_yaml(File.read(File.join(Rails.root, 'spec/fixtures/reports/success.yml')))
        report.status.should == 'unchanged'
      end

      it "should consider a blank report to be invalid" do
        lambda { Report.create_from_yaml('') }.should raise_error(ArgumentError)
      end

      it "should consider a report in incorrect format to be invalid" do
        lambda { Report.create_from_yaml('foo bar baz bad data invalid') }.should raise_error(ArgumentError)
      end

      it "should consider a report in correct format to be valid" do
        report_from_yaml.should be_valid
      end

      it "is not created if a report for the same host exists with the same time" do
        Report.create_from_yaml(@report_yaml)
        lambda {
          Report.create_from_yaml(@report_yaml)
        }.should raise_error(ActiveRecord::RecordInvalid)
        Report.count.should == 1
      end

      it "creates a node by host if none exists" do
        lambda {
          Report.create_from_yaml(@report_yaml)
        }.should change { Node.count(:conditions => {:name => @report_data.host}) }.by(1)
      end

      it "updates the node's reported_at timestamp" do
        node = Node.generate(:name => @report_data.host)
        report = Report.create_from_yaml(@report_yaml)
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

    def report_from_yaml(path="puppet25/1_changed_0_failures.yml" )
      report_yaml = File.read(Rails.root.join('spec', 'fixtures', 'reports', path))
      Report.create_from_yaml(report_yaml)
    end
  end

  describe "#failed_resources?" do
    it "should consider a report with metrics and no failing resources to be a success" do
      rep = Report.generate
      rep.metrics.stubs(:empty?).returns(false)
      rep.stubs(:failed_resources).returns(0)
      rep.should_not be_failed_resources
    end

    it "should consider a report with failing resources to be a failure" do
      rep = Report.generate
      rep.metrics.create(:category => "resources", :name => "failed", :value => 2)
      rep.should be_failed_resources
    end

    it "should consider a report with no metrics and no failing resources to be a failure" do
      rep = Report.generate
      rep.should be_failed_resources
    end
  end

  describe "when destroying the most recent report for a node" do
    before :each do
      @node = Node.generate!
      @report = Report.create!(:host => @node.name, :time => 1.week.ago.to_date, :status => 'unchanged')
    end

    it "should set the node's most recent report to what is now the most recent report" do
      @newer_report = Report.create!(:host => @node.name, :time => Time.now, :status => 'failed')
      # Time objects store higher resolution than time from the database, so we need to reload
      # so time matches what the node has
      @newer_report.reload
      @node.reload
      @node.last_report.should == @newer_report
      @node.reported_at.should == @newer_report.time
      @node.status.should == @newer_report.status

      @newer_report.destroy
      @node.reload

      @node.last_report.should == @report
      @node.reported_at.should == @report.time
      @node.status.should == @report.status
    end

    it "should clear the node's most recent report if there are no other reports" do
      @report.destroy
      @node.reload

      @node.last_report.should == nil
      @node.reported_at.should == nil
      @node.status.should == 'unchanged'
    end
  end

  describe "when diffing inspection reports" do
    def generate_report(time, file_ensure, file_content)
      Report.create_from_yaml <<-HEREDOC
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
          message: inspected value is :#{file_ensure}
          previous_value: !ruby/sym #{file_ensure}
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
          message: "inspected value is \\"{md5}#{file_content}\\""
          previous_value: "{md5}#{file_content}"
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
  time: #{time}
HEREDOC
    end

    it "should produce an empty diff for the same report twice" do
      report1 = generate_report(Time.now, "file", "foo")
      report2 = generate_report(1.week.ago, "file", "foo")
      report1.diff(report2).should == {}
    end

    it "should show diff for the different reports" do
      report1 = generate_report(Time.now, "file", "foo")
      report2 = generate_report(1.week.ago, "directory", "bar")
      report1.diff(report2).should == {
        'File[/tmp/foo]' => {
          :ensure => [:file, :directory],
          :content => ["{md5}foo", "{md5}bar"],
        }
      }
    end
  end

  describe "#create_from_yaml for a 2.6 report" do
    it "should populate report related tables from a yaml report" do
      @node = Node.generate(:name => 'puppet.puppetlabs.vm')
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      file = '/etc/puppet/manifests/site.pp'
      Report.create_from_yaml(@report_yaml)
      Report.count.should == 1
      report = Report.first
      report.node.should == @node
      report.metrics.map {|t| [t.category, t.name, "%0.2f" % t.value]}.should =~ [
        ['time',      'schedule'         ,  '0.00'],
        ['time',      'config_retrieval' ,  '0.16'],
        ['time',      'filebucket'       ,  '0.00'],
        ['time',      'service'          ,  '1.56'],
        ['time',      'exec'             ,  '0.10'],
        ['time',      'total'       ,  '1.82'],
        ['resources', 'total'            ,  '9.00'],
        ['resources', 'changed'          ,  '2.00'],
        ['resources', 'out_of_sync'      ,  '2.00'],
        ['changes',   'total'            ,  '2.00'],
        ['events',    'total'            ,  '2.00'],
        ['events',    'success'          ,  '2.00']
      ]

      report.resource_statuses.map { |t| [
        t.resource_type,
        t.title,
        "%0.2f" % t.evaluation_time,
        t.file,
        t.line,
        #t.source_description,
        t.tags.sort,
        #t.time,
        t.change_count
      ] }.should =~ [
        [ 'Filebucket' ,  'puppet'  ,  "0.00" ,  nil ,  nil ,  ['filebucket' ,  'puppet']   ,  0 ],
        [ 'Schedule'   ,  'puppet'  ,  "0.00" ,  nil ,  nil ,  ['puppet'     ,  'schedule'] ,  0 ],
        [ 'Schedule'   ,  'weekly'  ,  "0.00" ,  nil ,  nil ,  ['schedule'   ,  'weekly']   ,  0 ],
        [ 'Schedule'   ,  'daily'   ,  "0.00" ,  nil ,  nil ,  ['daily'      ,  'schedule'] ,  0 ],
        [ 'Schedule'   ,  'hourly'  ,  "0.00" ,  nil ,  nil ,  ['hourly'     ,  'schedule'] ,  0 ],
        [ 'Schedule'   ,  'monthly' ,  "0.00" ,  nil ,  nil ,  ['monthly'    ,  'schedule'] ,  0 ],
        [ 'Schedule'   ,  'never'   ,  "0.00" ,  nil ,  nil ,  ['never'      ,  'schedule'] ,  0 ],
        [ 'Service'    ,  'mysqld'  ,  "1.56" ,  file,  8 ,  ['class'      ,  'default'   ,  'mysqld' ,  'node' ,  'service'] ,  1 ],
        [ 'Exec'    ,  '/bin/true'  ,  "0.10" ,  file ,  9 ,  ['class'      ,  'default'   ,  'exec' ,  'node' ] ,  1 ],
      ]
      report.events.map { |t| [
        t.property,
        t.previous_value,
        t.desired_value,
        #t.message,
        t.name,
        #t.source_description,
        t.status,
        t.tags.sort,
      ] }.should =~ [
        [ 'returns' , :notrun  , ['0']    , 'executed_command' , 'success' , ['class' , 'default' , 'exec'   , 'node']            ],
        [ 'ensure'  , :stopped , :running , 'service_started'  , 'success' , ['class' , 'default' , 'mysqld' , 'node' , 'service']],
      ]

      report.logs.map { |t| [
        t.level,
        t.message,
        t.source,
        t.tags.sort,
        #t.time,
        t.file,
        t.line,
      ] }.should =~ [
        ['info', 'Caching catalog for puppet.puppetlabs.vm',    'Puppet', ['info'], nil, nil ],
        ['info', "Applying configuration version '1279826342'", 'Puppet', ['info'], nil, nil ],
        ['notice', 'executed successfully', "/Stage[main]//Node[default]/Exec[/bin/true]/returns", ['class', 'default', 'exec', 'node', 'notice'], file, 9 ],
        ['notice', "ensure changed 'stopped' to 'running'", '/Stage[main]//Node[default]/Service[mysqld]/ensure', ['class', 'default', 'mysqld', 'node', 'notice', 'service'], file, 8 ],
      ]
    end
  end

  describe "When destroying" do
    it "should destroy all dependent model objects" do
      @node = Node.generate(:name => 'puppet.puppetlabs.vm')
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      file = '/etc/puppet/manifests/site.pp'
      report = Report.create_from_yaml(@report_yaml)
      ResourceStatus.count.should_not == 0
      ResourceEvent.count.should_not == 0
      ReportLog.count.should_not == 0
      Metric.count.should_not == 0
      report.destroy
      ResourceStatus.count.should == 0
      ResourceEvent.count.should == 0
      ReportLog.count.should == 0
      Metric.count.should == 0
    end
  end
end
