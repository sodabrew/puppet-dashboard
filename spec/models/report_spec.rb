require 'spec_helper'

describe Report do
  include DescribeReports

  describe "on creation" do
    let :node do
      Node.generate
    end
    let :report_yaml do
      File.read(File.join(Rails.root, "spec/fixtures/sample_report.yml"))
    end
    let :raw_report do
      YAML.load(report_yaml, :safe => true, :deserialize_symbols => true)
    end

    before :each do
      now = Time.now
      Time.stubs(:now).returns(now)
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
      Report.create_from_yaml('').should == nil
      DelayedJobFailure.count.should == 1
      DelayedJobFailure.first.summary.should == 'Importing report'
      DelayedJobFailure.first.details.should == 'The supplied report did not deserialize into a Hash'
      DelayedJobFailure.first.backtrace.any? {|trace| trace =~ /report\.rb:\d+:in.*create_from_yaml/}.should be_true
    end

    it "should consider a report in incorrect format to be invalid" do
      Report.create_from_yaml('foo bar baz bad data invalid').should == nil
      DelayedJobFailure.count.should == 1
      DelayedJobFailure.first.summary.should == 'Importing report'
      DelayedJobFailure.first.details.should == 'The supplied report did not deserialize into a Hash'
      DelayedJobFailure.first.backtrace.any? {|trace| trace =~ /report\.rb:\d+:in.*create_from_yaml/}.should be_true
    end

    it "should consider a report in correct format to be valid" do
      report_yaml = File.read(Rails.root.join('spec', 'fixtures', 'reports', "puppet25/1_changed_0_failures.yml"))
      Report.create_from_yaml(report_yaml).should be_valid
    end

    it "is not created if a report for the same host exists with the same time and kind" do
      Report.create_from_yaml(report_yaml)
      Report.create_from_yaml(report_yaml)
      Report.count.should == 1
      DelayedJobFailure.count.should == 1
      DelayedJobFailure.first.summary.should == 'Importing report'
      DelayedJobFailure.first.details.should == 'Validation failed: Host already has a report for time and kind'
      DelayedJobFailure.first.backtrace.any? {|trace| trace =~ /report\.rb:\d+:in.*create_from_yaml/}.should be_true
    end

    it "creates a node by host if none exists" do
      lambda {
        Report.create_from_yaml(report_yaml)
      }.should change { Node.count(:conditions => {:name => raw_report['host']}) }.by(1)
    end

    it "updates the node's reported_at timestamp for apply reports" do
      node = Node.generate(:name => raw_report['host'])
      report = Report.create_from_yaml(report_yaml)
      node.reload
      node.reported_at.should be_within(1.second).of(raw_report['time'].in_time_zone)
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

  describe "post transformer munging" do
    let :report_yaml do
      File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/resource_status_test.yaml"))
    end
    let :report do
      Report.create_from_yaml(report_yaml)
    end

    it "should idempotently update statuses and metrics" do
      suc_rep = Factory.create(:successful_report)
      suc_rep.status.should == 'changed'
      suc_rep.metrics.should be_empty

      Factory.create(:pending_resource, :report => suc_rep)

      suc_rep.munge
      suc_rep.status.should == 'pending'
      suc_rep.metrics.map {|t| [t.category, t.name, t.value.to_i]}.should =~ [
        ['resources',      'pending' ,   1],
        ['resources',      'unchanged' , 0],
      ]
      suc_rep.resource_statuses.map {|rs| rs.status}.should =~ [ 'pending' ]

      suc_rep.munge
      suc_rep.status.should == 'pending'
      suc_rep.metrics.map {|t| [t.category, t.name, t.value.to_i]}.should =~ [
        ['resources',      'pending' ,   1],
        ['resources',      'unchanged' , 0],
      ]
      suc_rep.resource_statuses.map {|rs| rs.status}.should =~ [ 'pending' ]
    end

    it "should have a report status of failed if any resources have a status of failed" do
      report.status.should == 'failed'
      report.failed_resources.should == 1
    end

    it "should get the correct value for total_resources" do
      report.total_resources.should == 14
    end

    it "should get the correct value for failed_resources" do
      report.failed_resources.should == 1
    end

    it "should get the correct value for failed_restarts" do
      report.failed_restarts.should == 0
    end

    it "should get the correct value for skipped_resources" do
      report.skipped_resources.should == 1
    end

    it "should get the correct value for changed_resources" do
      report.changed_resources.should == 1
    end

    it "should get the correct value for total_time" do
      report.total_time.should == '0.13'
    end

    describe "calculated after the transformation in munge" do
      it "should correctly populate the 'status' of resource_statuses" do
        report.resource_statuses.map {|rs| [rs.title, rs.status]}.should =~ [
          ["puppet"                            ,  'unchanged'],
          ["monthly"                           ,  'unchanged'],
          ["never"                             ,  'unchanged'],
          ["weekly"                            ,  'unchanged'],
          ["puppet"                            ,  'unchanged'],
          ["hourly"                            ,  'unchanged'],
          ["/tmp/audit"                        ,  'unchanged'],
          ["daily"                             ,  'unchanged'],
          ["/tmp/noop_without_pending_changes" ,  'unchanged'],
          ["/tmp/compliant_without_changes"    ,  'unchanged'],
          ["/tmp/skipped"                      ,  'unchanged'],
          ["/tmp/noop_with_pending_changes"    ,  'pending'  ],
          ["/tmp/compliant_with_changes"       ,  'changed'  ],
          ["/etc/failure"                      ,  'failed'   ]
        ]
      end

      it "should get the correct value for pending_resources" do
        report.pending_resources.should == 1
      end

      it "should get the correct value for unchanged_resources" do
        report.unchanged_resources.should == 11
      end
    end
  end

  describe "#create_from_yaml" do
    it "should populate report related tables from a version 0 yaml report" do
      Time.zone = 'UTC'
      node = Node.generate(:name => 'sample_node')
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet25/1_changed_0_failures.yml"))
      Report.count.should == 0
      Report.create_from_yaml(report_yaml)
      Report.count.should == 1
      report = Report.first
      report.node.should == node
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
        ['resources', 'pending'          ,  '0.00'],
        ['resources', 'unchanged'        ,  '0.00'],
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
      node = Node.generate(:name => 'puppet.puppetlabs.vm')
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      file = '/etc/puppet/manifests/site.pp'
      Report.create_from_yaml(report_yaml)
      Report.count.should == 1
      report = Report.first
      report.node.should == node
      report.metrics.map {|t| [t.category, t.name, "%0.2f" % t.value]}.should =~ [
        ['time',      'schedule'         ,  '0.00'],
        ['time',      'config_retrieval' ,  '0.16'],
        ['time',      'filebucket'       ,  '0.00'],
        ['time',      'service'          ,  '1.56'],
        ['time',      'exec'             ,  '0.10'],
        ['time',      'total'            ,  '1.82'],
        ['resources', 'total'            ,  '9.00'],
        ['resources', 'changed'          ,  '2.00'],
        ['resources', 'unchanged'        ,  '7.00'],
        ['resources', 'pending'          ,  '0.00'],
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
        [ 'Exec'       ,'/bin/true' ,  "0.10" ,  file,  9   ,  ['class'      ,  'default'   ,  'exec'   ,  'node'             ] ,  1, true ],
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
      node = Node.generate(:name => 'paul-berrys-macbook-pro-3.local')
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/version2/example.yaml"))
      file = '/Users/pberry/puppet_labs/test_data/master/manifests/site.pp'
      Report.create_from_yaml(report_yaml)
      Report.count.should == 1

      report = Report.first
      report.node.should == node
      report.status.should == 'pending'
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
        ['resources', 'pending'          ,  '1.00'],
        ['resources', 'unchanged'        ,  '8.00'],
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

  describe "#create_from_yaml_file" do
    let(:myStubbedClass) {
      #we've had some really weird issues with mocha stub pollution in Ruby 1.8.7
      #this subclass should resolve it
      k = Class.new(Report)
      k.table_name = Report.table_name
      k
    }

    describe "when create_from_yaml is successful" do
      before do
        myStubbedClass.expects(:read_file_contents).with('/tmp/foo').returns('---')
        myStubbedClass.expects(:create_from_yaml).returns('i can haz report')
      end

      it "should call create_from_yaml on the file passed in and return the results" do
        myStubbedClass.create_from_yaml_file('/tmp/foo').should == "i can haz report"
      end

      it "should delete the file if delete option is specified" do
        myStubbedClass.expects(:remove_file).with('/tmp/foo')
        myStubbedClass.create_from_yaml_file('/tmp/foo', :delete => true)
      end
    end


    describe "when create_from_yaml fails" do
      before do
        myStubbedClass.expects(:read_file_contents).at_least_once.with('/tmp/foo').returns('---')
      end

      it "not unlink the file if create_from_yaml fails" do
        myStubbedClass.expects(:remove_file).with('/tmp/foo').never
        myStubbedClass.stubs(:create_from_yaml).returns(nil)
        myStubbedClass.create_from_yaml_file('/tmp/foo', :delete => true)
      end

      it "should return nil if create_from_yaml fails" do
        myStubbedClass.expects(:create_from_yaml).with('---').returns(nil)
        myStubbedClass.create_from_yaml_file('/tmp/foo').should == nil
      end
    end
  end


  describe "When destroying" do
    it "should destroy all dependent model objects" do
      node = Node.generate(:name => 'puppet.puppetlabs.vm')
      report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
      file = '/etc/puppet/manifests/site.pp'
      report = Report.create_from_yaml(report_yaml)
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
    let :node do
      Node.generate(:name => "my_node")
    end

    ["apply", "inspect"].each do |kind|
      other_kind = kind == "apply" ? "inspect" : "apply"

      describe "from an #{kind} report" do

        describe "when creating the first report" do
          let :report do
            node.last_apply_report.should == nil
            node.last_inspect_report.should == nil
            node.reported_at.should == nil

            report = Report.generate(:host => "my_node", :time => Time.now, :kind => kind)

            node.reload

            report
          end

          before :each do
            report # force creation
          end

          it "should set the last_#{kind}_report to the report" do
            node.send("last_#{kind}_report").should == report
            node.send("last_#{other_kind}_report").should == nil
          end

          if kind == "apply"
            it "should set the reported_at time to the report's time" do
              node.reported_at.to_s.should == report.time.to_s
              node.reported_at.to_i.should == report.time.to_i
            end
          end
        end

        describe "when creating a subsequent report" do
          let :old_apply_report do
            node # force creation
            Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply")
          end
          let :old_inspect_report do
            node # force creation
            Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect")
          end
          let :report do
            node # force creation
            old_apply_report # force creation
            old_inspect_report # force creation

            node.reload
            node.last_apply_report.should == old_apply_report
            node.last_inspect_report.should == old_inspect_report
            node.reported_at.to_s.should == old_apply_report.time.to_s

            report = Report.generate(:host => "my_node", :time => Time.now, :kind => kind)

            node.reload

            report
          end

          before :each do
            report # force creation
          end

          it "should set the last_#{kind}_report to the report" do
            node.send("last_#{kind}_report").should == report
            node.send("last_#{other_kind}_report").should == ( other_kind == "apply" ? old_apply_report : old_inspect_report )
          end

          if kind == "apply"
            it "should set the reported_at time to the report's time" do
              node.reported_at.to_s.should == report.time.to_s
              node.reported_at.to_i.should == report.time.to_i
            end
          end
        end

        describe "when creating a prior report" do
          let :old_apply_report do
            node # force creation
            Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply")
          end
          let :old_inspect_report do
            node # force creation
            Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect")
          end

          before :each do
            node # force creation
            old_apply_report # force creation
            old_inspect_report # force creation

            node.reload
            node.last_apply_report.should == old_apply_report
            node.last_inspect_report.should == old_inspect_report
            node.reported_at.to_s.should == old_apply_report.time.to_s

            Report.generate(:host => "my_node", :time => 3.hours.ago, :kind => kind)

            node.reload
          end

          it "should not change any of last_apply_report, last_inspect_report, or reported_at" do
            node.last_apply_report.should == old_apply_report
            node.last_inspect_report.should == old_inspect_report
            node.reported_at.to_s.should == old_apply_report.time.to_s
          end
        end

        describe "when deleting the latest report" do
          let :older_apply_report do
            node # force creation
            Report.generate(:host => "my_node", :time => 3.hours.ago, :kind => "apply",   :status => "changed")
          end
          let :older_inspect_report do
            node # force creation
            Report.generate(:host => "my_node", :time => 4.hours.ago, :kind => "inspect", :status => "unchanged")
          end

          before :each do
            node # force creation
            newer_apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply",   :status => "failed")
            newer_inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect", :status => "unchanged")
            older_apply_report # force creation
            older_inspect_report # force creation

            Report.count.should == 4

            node.reload
            node.last_apply_report.should == newer_apply_report
            node.last_inspect_report.should == newer_inspect_report
            node.reported_at.to_s.should == newer_apply_report.time.to_s

            node.send("last_#{kind}_report").destroy

            node.reload
          end

          it "should set the last_#{kind}_report to the next most recent report" do
            node.send("last_#{kind}_report").should == ( kind == "apply" ? older_apply_report : older_inspect_report )
          end

          if kind == "apply"
            it "should set the reported_at time to the next most recent report's time" do
              node.reported_at.to_s.should == older_apply_report.time.to_s
            end

            it "should set the node status to the next most recent report's status" do
              node.status.should == older_apply_report.status
            end
          end
        end

        describe "when deleting the only report" do
          before :each do
            node # force creation
            apply_report   = Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply",   :status => "failed")
            inspect_report = Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect", :status => "unchanged")

            Report.count.should == 2

            node.reload
            node.last_apply_report.should == apply_report
            node.last_inspect_report.should == inspect_report
            node.reported_at.to_s.should == apply_report.time.to_s
            node.status.should == "failed"

            node.send("last_#{kind}_report").destroy

            node.reload
          end

          it "should set the last_#{kind}_report to nil" do
            node.send("last_#{kind}_report").should == nil
          end

          if kind == "apply"
            it "should set the reported_at time to nil" do
              node.reported_at.should == nil
            end

            it "should set the node status to nil" do
              node.status.should == nil
            end
          end
        end
      end

      describe "when deleting some historical report" do
        let :newer_apply_report do
          node # force creation
          Report.generate(:host => "my_node", :time =>  1.hour.ago, :kind => "apply",   :status => "failed")
        end
        let :newer_inspect_report do
          node # force creation
          Report.generate(:host => "my_node", :time => 2.hours.ago, :kind => "inspect", :status => "unchanged")
        end

        before :each do
          node # force creation
          newer_apply_report # force creation
          newer_inspect_report # force creation
          older_apply_report   = Report.generate(:host => "my_node", :time => 3.hours.ago, :kind => "apply",   :status => "changed")
          older_inspect_report = Report.generate(:host => "my_node", :time => 4.hours.ago, :kind => "inspect", :status => "unchanged")

          Report.count.should == 4

          node.reload
          node.last_apply_report.should == newer_apply_report
          node.last_inspect_report.should == newer_inspect_report
          node.reported_at.to_s.should == newer_apply_report.time.to_s

          older_apply_report.destroy
          older_inspect_report.destroy
          node.reload
        end

        it "should not change any of last_apply_report, last_inspect_report, reported_at, or status" do
          node.last_apply_report.should == newer_apply_report
          node.last_inspect_report.should == newer_inspect_report
          node.reported_at.to_s.should == newer_apply_report.time.to_s
          node.status.should == newer_apply_report.status
        end
      end

    end
  end

end
