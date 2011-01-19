require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  include DescribeReports

  describe "on creation" do
    before :each do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @node = Node.generate
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/sample_report.yml"))
      @report_data = YAML.load(@report_yaml).extend(ReportExtensions)
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
      report_yaml = File.read(Rails.root.join('spec', 'fixtures', 'reports', "puppet25/1_changed_0_failures.yml"))
      Report.create_from_yaml(report_yaml).should be_valid
    end

    it "is not created if a report for the same host exists with the same time and kind" do
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

    it "updates the node's reported_at timestamp for apply reports" do
      node = Node.generate(:name => @report_data.host)
      report = Report.create_from_yaml(@report_yaml)
      node.reload
      node.reported_at.should be_close(@report_data.time.in_time_zone, 1.second)
    end

    it "does not update the node's reported_at timestamp for inspect reports" do
      node = Node.generate
      report = Report.generate!(:kind => "inspect", :host => node.name)
      node.reload
      node.reported_at.should == nil
    end

    it "should update the node's last report for apply reports" do
      node = Node.generate!
      report = Report.create!(:host => node.name, :time => Time.now, :kind => "apply")
      node.reload
      node.last_apply_report.should == report
    end

    it "should not update the node's last report for inspect reports" do
      node = Node.generate
      report = Report.create!(:host => node.name, :time => Time.now, :kind => "inspect")
      node.reload
      node.last_apply_report.should_not == report
    end
  end

  describe "metrics methods" do
    before :each do
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      @report = Report.create_from_yaml(@report_yaml)
    end

    it "should get the correct value for total_resources" do
      @report.total_resources.should == 9
    end

    it "should get the correct value for failed_resources" do
      @report.failed_resources.should == 0
    end

    it "should get the correct value for failed_restarts" do
      @report.failed_restarts.should == 0
    end

    it "should get the correct value for skipped_resources" do
      @report.skipped_resources.should == 0
    end

    it "should get the correct value for changed_resources" do
      @report.changed_resources.should == 2
    end

    it "should get the correct value for total_time" do
      @report.total_time.should == '1.82'
    end
  end

  describe "when diffing inspection reports" do
    def generate_report(time, file_ensure, file_content, resource_name = "/tmp/foo")
      report_yaml = <<-HEREDOC
--- !ruby/object:Puppet::Transaction::Report
  report_format: 2
  host: mattmac.puppetlabs.lan
  kind: inspect
  logs: []
  metrics: {}
  resource_statuses: 
    "File[#{resource_name}]": !ruby/object:Puppet::Resource::Status
      evaluation_time: 0.000868
      file: &id001 /Users/matthewrobinson/work/puppet/test_data/genreportm/manifests/site.pp
      line: 5
      resource_type: File
      title: #{resource_name}
      source_description: "/Stage[main]//Node[default]/File[#{resource_name}]"
      tags:
        - &id002 file
        - node
        - default
        - &id003 class
      time: 2010-07-22 14:42:39.654436 -04:00
      failed: false
      events: 
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: *id001
          line: 5
          message: inspected value is :#{file_ensure}
          previous_value: !ruby/sym #{file_ensure}
          property: ensure
          resource: "File[#{resource_name}]"
          status: audit
          tags: 
            - *id002
            - *id003
          time: 2010-12-03 12:18:40.039434 -08:00
HEREDOC
      if file_content
        report_yaml << <<-HEREDOC
        - !ruby/object:Puppet::Transaction::Event
          default_log_level: !ruby/sym notice
          file: *id001
          line: 5
          message: "inspected value is \\"{md5}#{file_content}\\""
          previous_value: "{md5}#{file_content}"
          property: content
          resource: "File[#{resource_name}]"
          status: audit
          tags: 
            - *id002
            - *id003
          time: 2010-12-03 12:08:59.061376 -08:00
HEREDOC
      end
      report_yaml << "  time: #{time}\n"
      Report.create_from_yaml report_yaml
    end

    it "should produce a diff with no changes for the same report twice" do
      report1 = generate_report(Time.now, "file", "foo")
      report2 = generate_report(1.week.ago, "file", "foo")
      report_diff = report1.diff(report2)
      report_diff.should == { "File[/tmp/foo]" => {} }
      Report.divide_diff_into_pass_and_fail(report_diff).should == { 
        :pass    => ["File[/tmp/foo]"],
        :failure => []
      }
    end

    it "should show diff for the different reports" do
      report1 = generate_report(Time.now, "file", "foo")
      report2 = generate_report(1.week.ago, "directory", "bar")
      report_diff = report1.diff(report2)
      
      report_diff.should == {
        'File[/tmp/foo]' => {
          :ensure => [:file, :directory],
          :content => ["{md5}foo", "{md5}bar"],
        }
      }
      Report.divide_diff_into_pass_and_fail(report_diff).should == { 
        :pass    => [],
        :failure => ["File[/tmp/foo]"]
      }
    end

    it "should output nils appropriately for resources that are missing from either report" do
      report1 = generate_report(Time.now, "file", "foo", "/tmp/foo")
      report2 = generate_report(1.week.ago, "file", "foo", "/tmp/bar")
      report_diff = report1.diff(report2)

      report_diff.should == {
        'File[/tmp/foo]' => {
          :ensure => [:file, nil],
          :content => ["{md5}foo", nil],
        },
        'File[/tmp/bar]' => {
          :ensure => [nil, :file],
          :content => [nil, "{md5}foo"],
        }
      }
      Report.divide_diff_into_pass_and_fail(report_diff).should == { 
        :pass    => [],
        :failure => ["File[/tmp/foo]", "File[/tmp/bar]"]
      }
    end

    it "should output nils appropriately for properties that are missing from either report" do
      report1 = generate_report(Time.now, "file", "foo")
      report2 = generate_report(1.week.ago, "absent", nil)
      report1.diff(report2).should == {
        'File[/tmp/foo]' => {
          :ensure => [:file, :absent],
          :content => ["{md5}foo", nil],
        }
      }
      report2.diff(report1).should == {
        'File[/tmp/foo]' => {
          :ensure => [:absent, :file],
          :content => [nil, "{md5}foo"],
        }
      }
    end

    describe ".inspections" do
      it "should include inspect reports" do
        @report = generate_report(Time.now, "file", "foo")
        @report.save!
        Report.inspections.should == [@report]
      end
    end

    describe "baseline!" do
      before do
        @report  = generate_report(Time.now, "file", "foo")
        @report2 = generate_report(1.week.ago, "absent", nil)
      end

      it "should set baseline?" do
        @report.baseline!

        @report.reload
        @report.should be_baseline

        Report.baselines.should == [@report]
      end

      it "should unset other reports' baseline?" do
        @report.should_not be_baseline
        @report2.should_not be_baseline

        @report.baseline!
        @report.reload
        @report.should be_baseline
        @report2.should_not be_baseline

        @report2.baseline!
        @report2.should be_baseline

        @report.reload
        @report.should_not be_baseline

        Report.baselines.should == [@report2]
      end

      it "should not make non-inspection reports baselines" do
        @apply_report = Report.generate!(:kind => "apply")
        lambda { @apply_report.baseline! }.should raise_error(IncorrectReportKind)

        @apply_report.should_not be_baseline
      end
    end

  end

  describe "#create_from_yaml" do
    it "should populate report related tables from a version 0 yaml report" do
      Time.zone = 'UTC'
      @node = Node.generate(:name => 'sample_node')
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/reports/puppet25/1_changed_0_failures.yml"))
      Report.count.should == 0
      Report.create_from_yaml(@report_yaml)
      Report.count.should == 1
      report = Report.first
      report.node.should == @node
      report.metrics.map {|t| [t.category, t.name, "%0.2f" % t.value]}.should =~ [
        ['time',      'config_retrieval' ,  '0.19'],
        ['time',      'file'             ,  '0.07'],
        ['time',      'total'            ,  '0.25'],
        ['resources', 'out_of_sync'      ,  '1.00'],
        ['resources', 'scheduled'        ,  '1.00'],
        ['resources', 'skipped'          ,  '0.00'],
        ['resources', 'applied'          ,  '1.00'],
        ['resources', 'restarted'        ,  '0.00'],
        ['resources', 'failed_restarts'  ,  '0.00'],
        ['resources', 'failed'           ,  '0.00'],
        ['resources', 'total'            ,  '3.00'],
        ['changes',   'total'            ,  '1.00'],
      ]

      report.resource_statuses.count.should == 0
      report.events.count.should == 0
      report.logs.map { |t| [
        t.level,
        t.message,
        t.source,
        t.tags.sort,
        t.time.strftime("%Y-%m-%d %H:%M:%S"),
        t.file,
        t.line,
      ] }.should =~ [
        ['info', "Applying configuration version '1258679330'", 'Puppet', ['info'], '2009-11-20 01:08:50', nil, nil],
        ['info', 'Adding /tmp/puppet_test(6d0007e52f7afb7d5a0650b0ffb8a4d1)', 'Filebucket[/tmp/puppet/var/clientbucket]', ['info'], '2009-11-20 01:08:50', nil, nil],
        ['info', 'Filebucketed /tmp/puppet_test to puppet with sum 6d0007e52f7afb7d5a0650b0ffb8a4d1', '//Node[default]/File[/tmp/puppet_test]', ['class', 'default', 'file', 'info', 'main', 'node'], '2009-11-20 01:08:50', '/tmp/puppet/manifests/site.pp', 4],
        ['notice', "content changed '{md5}6d0007e52f7afb7d5a0650b0ffb8a4d1' to 'unknown checksum'", '//Node[default]/File[/tmp/puppet_test]/content', ['class', 'content', 'default', 'file', 'main', 'node', 'notice'], '2009-11-20 01:08:50', '/tmp/puppet/manifests/site.pp', 4]
      ]

      report.configuration_version.should == '1258679330'
      report.puppet_version.should == '0.25.x'
      report.status.should == 'changed'
    end

      it "should populate report related tables from a version 1 yaml report" do
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
          ['time',      'total'            ,  '1.82'],
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
          t.change_count,
          t.failed
        ] }.should =~ [
          [ 'Filebucket' ,  'puppet'  ,  "0.00" ,  nil ,  nil ,  ['filebucket' ,  'puppet']   ,  0, false ],
          [ 'Schedule'   ,  'puppet'  ,  "0.00" ,  nil ,  nil ,  ['puppet'     ,  'schedule'] ,  0, false ],
          [ 'Schedule'   ,  'weekly'  ,  "0.00" ,  nil ,  nil ,  ['schedule'   ,  'weekly']   ,  0, false ],
          [ 'Schedule'   ,  'daily'   ,  "0.00" ,  nil ,  nil ,  ['daily'      ,  'schedule'] ,  0, false ],
          [ 'Schedule'   ,  'hourly'  ,  "0.00" ,  nil ,  nil ,  ['hourly'     ,  'schedule'] ,  0, false ],
          [ 'Schedule'   ,  'monthly' ,  "0.00" ,  nil ,  nil ,  ['monthly'    ,  'schedule'] ,  0, false ],
          [ 'Schedule'   ,  'never'   ,  "0.00" ,  nil ,  nil ,  ['never'      ,  'schedule'] ,  0, false ],
          [ 'Service'    ,  'mysqld'  ,  "1.56" ,  file,  8   ,  ['class'      ,  'default'   ,  'mysqld' ,  'node' ,  'service'] ,  1, false ],
          [ 'Exec'       ,'/bin/true' ,  "0.10" ,  file ,  9  ,  ['class'      ,  'default'   ,  'exec' ,  'node' ] ,  1, true ],
        ]
        report.events.map { |t| [
          t.property,
          t.previous_value,
          t.desired_value,
          t.name,
          t.status,
        ] }.should =~ [
          [ 'returns' , :notrun  , ['0']    , 'executed_command' , 'success' ],
          [ 'ensure'  , :stopped , :running , 'service_started'  , 'success' ],
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

      report.configuration_version.should == '1279826342'
      report.puppet_version.should == '2.6.0'
      report.status.should == 'changed'
    end

    it "should populate report related tables from a version 2 report" do
      @node = Node.generate(:name => 'paul-berrys-macbook-pro-3.local')
      @report_yaml = File.read(File.join(RAILS_ROOT, "spec/fixtures/reports/version2/example.yaml"))
      file = '/Users/pberry/puppet_labs/test_data/master/manifests/site.pp'
      Report.create_from_yaml(@report_yaml)
      Report.count.should == 1

      report = Report.first
      report.node.should == @node
      report.status.should == 'changed'
      report.configuration_version.should == '1293756667'
      report.puppet_version.should == '2.6.4'

      report.metrics.map {|t| [t.category, t.name, "%0.2f" % t.value]}.should =~ [
        ['time',      'schedule'         ,  '0.00'],
        ['time',      'config_retrieval' ,  '0.07'],
        ['time',      'filebucket'       ,  '0.00'],
        ['time',      'file'             ,  '0.01'],
        ['time',      'total'            ,  '0.08'],
        ['resources', 'total'            , '12.00'],
        ['resources', 'out_of_sync'      ,  '4.00'],
        ['resources', 'changed'          ,  '3.00'],
        ['changes',   'total'            ,  '3.00'],
        ['events',    'total'            ,  '4.00'],
        ['events',    'success'          ,  '3.00'],
        ['events',    'audit'            ,  '1.00']
      ]

      report.resource_statuses.map { |t| [
        t.resource_type,
        t.title,
        "%0.3f" % t.evaluation_time,
        t.file,
        t.line,
        t.tags.sort,
        #t.time,
        t.change_count,
        t.out_of_sync_count,
        t.failed
      ] }.should =~ [
        [ 'Filebucket' ,  'puppet'  ,  "0.000" ,  nil ,  nil ,  ['filebucket' ,  'puppet']   ,  0 , 0 , false ],
        [ 'Schedule'   ,  'monthly' ,  "0.000" ,  nil ,  nil ,  ['monthly'    ,  'schedule'] ,  0 , 0 , false ],
        [ 'File' , '/tmp/unchanged' ,  "0.001" ,  file,  7   ,  ['class'      ,  'file']     ,  0 , 0 , false ],
        [ 'File' , '/tmp/noop'      ,  "0.001" ,  file,  7   ,  ['class'      ,  'file']     ,  0 , 1 , false ],
        [ 'Schedule'   ,  'never'   ,  "0.000" ,  nil ,  nil ,  ['never'      ,  'schedule'] ,  0 , 0 , false ],
        [ 'Schedule'   ,  'weekly'  ,  "0.000" ,  nil ,  nil ,  ['schedule'   ,  'weekly']   ,  0 , 0 , false ],
        [ 'File' , '/tmp/removed'   ,  "0.004" ,  file,  7   ,  ['class'      ,  'file']     ,  1 , 1 , false ],
        [ 'File' , '/tmp/created'   ,  "0.001" ,  file,  7   ,  ['class'      ,  'file']     ,  1 , 1 , false ],
        [ 'Schedule'   ,  'puppet'  ,  "0.000" ,  nil ,  nil ,  ['puppet'     ,  'schedule'] ,  0 , 0 , false ],
        [ 'Schedule'   ,  'daily'   ,  "0.000" ,  nil ,  nil ,  ['daily'      ,  'schedule'] ,  0 , 0 , false ],
        [ 'File' , '/tmp/changed'   ,  "0.001" ,  file,  7   ,  ['class'      ,  'file']     ,  1 , 1 , true  ],
        [ 'Schedule'   ,  'hourly'  ,  "0.000" ,  nil ,  nil ,  ['hourly'     ,  'schedule'] ,  0 , 0 , false ],
      ]
      report.events.map { |t| [
        t.property,
        t.previous_value.to_s,
        t.desired_value.to_s,
        t.historical_value.to_s,
        #t.message,
        t.name,
        t.status,
        t.audited,
      ] }.should =~ [
        [ 'owner'  , '0'     , ''       , '501' , 'owner_changed' , 'audit'   , true  ],
        [ 'mode'   , '640'   , '644'    , ''    , 'mode_changed'  , 'noop'    , false ],
        [ 'ensure' , 'file'  , 'absent' , ''    , 'file_removed'  , 'success' , false ],
        [ 'ensure' , 'absent', 'present', ''    , 'file_created'  , 'success' , false ],
        [ 'mode'   , '640'   , '644'    , ''    , 'mode_changed'  , 'success' , false ],
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
        ['debug', 'Using cached certificate for ca', 'Puppet', ['debug'], nil, nil],
        ['debug', 'Using cached certificate for paul-berrys-macbook-pro-3.local', 'Puppet', ['debug'], nil, nil],
        ['debug', 'Using cached certificate_revocation_list for ca', 'Puppet', ['debug'], nil, nil],
        ['debug', 'catalog supports formats: b64_zlib_yaml dot marshal pson raw yaml; using pson', 'Puppet', ['debug'], nil, nil],
        ['info', 'Caching catalog for paul-berrys-macbook-pro-3.local', 'Puppet', ['info'], nil, nil],
        ['debug', 'Creating default schedules', 'Puppet', ['debug'], nil, nil],
        ['debug', 'Loaded state in 0.00 seconds', 'Puppet', ['debug'], nil, nil],
        ['info', "Applying configuration version '1293756667'", 'Puppet', ['info'], nil, nil],
        ['notice', "audit change: previously recorded value pberry has been changed to root", "/Stage[main]//File[/tmp/unchanged]/owner", ['class', 'file', 'notice'], file, 7],
        ['notice', "mode changed '640' to '644'", "/Stage[main]//File[/tmp/changed]/mode", ['class', 'file', 'notice'], file, 7],
        ['debug', 'Finishing transaction 2166421680', 'Puppet', ['debug'], nil, nil],
        ['info', "FileBucket got a duplicate file /private/tmp/removed ({md5}d41d8cd98f00b204e9800998ecf8427e)", 'Puppet', ['info'], nil, nil],
        ['info', 'Filebucketed /tmp/removed to puppet with sum d41d8cd98f00b204e9800998ecf8427e', "/Stage[main]//File[/tmp/removed]", ['class', 'file', 'info'], file, 7],
        ['debug', 'Removing existing file for replacement with absent', "/Stage[main]//File[/tmp/removed]", ['class', 'debug', 'file'], file, 7],
        ['notice', 'removed', "/Stage[main]//File[/tmp/removed]/ensure", ['class', 'file', 'notice'], file, 7],
        ['notice', 'created', "/Stage[main]//File[/tmp/created]/ensure", ['class', 'file', 'notice'], file, 7],
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

  describe "when submitting reports" do
    it "should be able to save an inspect report and an apply report with the same timestamp" do
      time = Time.now
      Report.generate(:host => "my_node", :time => time, :kind => "apply")
      Report.generate(:host => "my_node", :time => time, :kind => "inspect")

      Report.count.should == 2
    end
  end

  describe "setting denormalized fields on node" do
    before :each do
      @node = Node.generate(:name => "my_node")
    end

    ["apply", "inspect"].each do |kind|
      other_kind = kind == "apply" ? "inspect" : "apply"

      describe "from an #{kind} report" do

        describe "when creating the first report" do
          before :each do
            @node.last_apply_report.should == nil
            @node.last_inspect_report.should == nil
            @node.reported_at.should == nil

            @report = Report.generate(:host => "my_node", :time => Time.now, :kind => kind)
            @node.reload
          end

          it "should set the last_#{kind}_report to the report" do
            @node.send("last_#{kind}_report").should == @report
            @node.send("last_#{other_kind}_report").should == nil
          end

          if kind == "apply"
            it "should set the reported_at time to the report's time" do
              @node.reported_at.to_s.should == @report.time.to_s
              @node.reported_at.to_i.should == @report.time.to_i
            end
          end
        end

        describe "when creating a subsequent report" do
          before :each do
            @old_apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply")
            @old_inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect")
            @node.reload
            @node.last_apply_report.should == @old_apply_report
            @node.last_inspect_report.should == @old_inspect_report
            @node.reported_at.to_s.should == @old_apply_report.time.to_s

            @report = Report.generate(:host => "my_node", :time => Time.now, :kind => kind)

            @node.reload
          end

          it "should set the last_#{kind}_report to the report" do
            @node.send("last_#{kind}_report").should == @report
            @node.send("last_#{other_kind}_report").should == ( other_kind == "apply" ? @old_apply_report : @old_inspect_report )
          end

          if kind == "apply"
            it "should set the reported_at time to the report's time" do
              @node.reported_at.to_s.should == @report.time.to_s
              @node.reported_at.to_i.should == @report.time.to_i
            end
          end
        end

        describe "when creating a prior report" do
          before :each do
            @old_apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply")
            @old_inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect")
            @node.reload
            @node.last_apply_report.should == @old_apply_report
            @node.last_inspect_report.should == @old_inspect_report
            @node.reported_at.to_s.should == @old_apply_report.time.to_s

            @report = Report.generate(:host => "my_node", :time => 3.hours.ago, :kind => kind)
            @node.reload
          end

          it "should not change any of last_apply_report, last_inspect_report, or reported_at" do
            @node.last_apply_report.should == @old_apply_report
            @node.last_inspect_report.should == @old_inspect_report
            @node.reported_at.to_s.should == @old_apply_report.time.to_s
          end
        end

        describe "when deleting the latest report" do
          before :each do
            @newer_apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply",   :status => "failed")
            @newer_inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect", :status => "unchanged")
            @older_apply_report   = Report.generate(:host => "my_node", :time => 3.hours.ago, :kind => "apply",   :status => "changed")
            @older_inspect_report = Report.generate(:host => "my_node", :time => 4.hours.ago, :kind => "inspect", :status => "unchanged")

            Report.count.should == 4

            @node.reload
            @node.last_apply_report.should == @newer_apply_report
            @node.last_inspect_report.should == @newer_inspect_report
            @node.reported_at.to_s.should == @newer_apply_report.time.to_s

            @report = @node.send("last_#{kind}_report")
            @report.destroy
            @node.reload
          end

          it "should set the last_#{kind}_report to the next most recent report" do
            @node.send("last_#{kind}_report").should == ( kind == "apply" ? @older_apply_report : @older_inspect_report )
          end

          if kind == "apply"
            it "should set the reported_at time to the next most recent report's time" do
              @node.reported_at.to_s.should == @older_apply_report.time.to_s
            end

            it "should set the node status to the next most recent report's status" do
              @node.status.should == @older_apply_report.status
            end
          end
        end

        describe "when deleting the only report" do
          before :each do
            @apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply",   :status => "failed")
            @inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect", :status => "unchanged")

            Report.count.should == 2

            @node.reload
            @node.last_apply_report.should == @apply_report
            @node.last_inspect_report.should == @inspect_report
            @node.reported_at.to_s.should == @apply_report.time.to_s
            @node.status.should == "failed"

            @report = @node.send("last_#{kind}_report")
            @report.destroy
            @node.reload
          end

          it "should set the last_#{kind}_report to nil" do
            @node.send("last_#{kind}_report").should == nil
          end

          if kind == "apply"
            it "should set the reported_at time to nil" do
              @node.reported_at.should == nil
            end

            it "should set the node status to nil" do
              @node.status.should == nil
            end
          end
        end
      end

      describe "when deleting some historical report" do
        before :each do
          @newer_apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply",   :status => "failed")
          @newer_inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect", :status => "unchanged")
          @older_apply_report   = Report.generate(:host => "my_node", :time => 3.hours.ago, :kind => "apply",   :status => "changed")
          @older_inspect_report = Report.generate(:host => "my_node", :time => 4.hours.ago, :kind => "inspect", :status => "unchanged")

          Report.count.should == 4

          @node.reload
          @node.last_apply_report.should == @newer_apply_report
          @node.last_inspect_report.should == @newer_inspect_report
          @node.reported_at.to_s.should == @newer_apply_report.time.to_s

          @older_apply_report.destroy
          @older_inspect_report.destroy
          @node.reload
        end

        it "should not change any of last_apply_report, last_inspect_report, reported_at, or status" do
          @node.last_apply_report.should == @newer_apply_report
          @node.last_inspect_report.should == @newer_inspect_report
          @node.reported_at.to_s.should == @newer_apply_report.time.to_s
          @node.status.should == @newer_apply_report.status
        end
      end

    end
  end

end
