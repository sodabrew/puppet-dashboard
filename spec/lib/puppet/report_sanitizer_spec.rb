require 'spec_helper'

describe ReportSanitizer do
  extend DescribeReports

  describe 'when sanitizing' do

    let(:formats_dir) do
      Rails.root.join('spec', 'fixtures', 'reports', 'formats')
    end
    let(:report_filename) do
      File.join(formats_dir, report_file)
    end
    let(:raw_report) do
      YAML.load_file(report_filename, safe: :true, deserialize_symbols: true)
    end

    describe 'a format version 0 (puppet 0.25.x) report' do
      let(:report_file) { '00_changes.yaml' }

      it "should produce a hash of the report" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics report_format}
        hash["report_format"].should == 0
        hash["host"].should == "sample_node"
        hash["time"].should == Time.parse("2009-11-19 17:08:50.631428 -08:00")
      end

      it "should include the logs" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash["logs"].should be_an(Array)

        logs = hash["logs"]
        logs.should == [{
          "level" => "info",
          "message" => "Applying configuration version '1258679330'",
          "source" => "Puppet",
          "tags" => ["info"],
          "time" => Time.parse("2009-11-19 17:08:50.557829 -08:00"),
          "file" => nil,
          "line" => nil,
          "version" => nil
        },
        {
          "line" => nil,
          "time" => Time.parse("2009-11-19 17:08:50.605975 -08:00"),
          "level" => "info",
          "tags" => ["info"],
          "file" => nil,
          "source" => "Filebucket[/tmp/puppet/var/clientbucket]",
          "message" => "Adding /tmp/puppet_test(6d0007e52f7afb7d5a0650b0ffb8a4d1)",
          "version" => nil
        },
        {
          "level" => "info",
          "message" => "Filebucketed /tmp/puppet_test to puppet with sum 6d0007e52f7afb7d5a0650b0ffb8a4d1",
          "source" => "//Node[default]/File[/tmp/puppet_test]",
          "tags" => ["file", "node", "default", "class", "main", "info"],
          "time" => Time.parse("2009-11-19 17:08:50.607171 -08:00"),
          "file" => "/tmp/puppet/manifests/site.pp",
          "line" => 4,
          "version" => 1258679330,
        },
        {
          "line" => 4,
          "time" => Time.parse("2009-11-19 17:08:50.625690 -08:00"),
          "level" => "notice",
          "tags" => ["file", "node", "default", "class", "main", "content", "notice"],
          "file" => "/tmp/puppet/manifests/site.pp",
          "source" => "//Node[default]/File[/tmp/puppet_test]/content",
          "message" => "content changed '{md5}6d0007e52f7afb7d5a0650b0ffb8a4d1' to 'unknown checksum'",
          "version" => 1258679330
        }]
      end

      it "should include the metrics" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash["metrics"].should be_a(Hash)
        metrics = hash["metrics"]
        metrics.should == {
          "time" => {
            "config_retrieval" => 0.185256958007812,
            "total" => 0.253255844116211,
            "file" => 0.0679988861083984
          },
          "resources" => {
            "failed" => 0,
            "total" => 3,
            "scheduled" => 1,
            "restarted" => 0,
            "skipped" => 0,
            "out_of_sync" => 1,
            "applied" => 1,
            "failed_restarts" => 0
          },
          "changes" => {
            "total" => 1
          }
        }
      end
    end

    describe 'a format version 1 (puppet 2.6.0-2.6.4) report' do
      let(:report_file) { '01_changes.yaml' }

      it "should fill in change_count=0 wherever a report is missing change_count attributes" do
        report_yaml = File.read(report_filename)
        report_yaml.gsub!(/^ *change_count: [0-9]+\n/, '').should be_truthy
        raw_report = YAML.load(report_yaml, :safe => :true, :deserialize_symbols => true)
        hash = ReportSanitizer.sanitize(raw_report)
        hash["resource_statuses"].values.each do |resource_status|
          resource_status["change_count"].should == 0
        end
      end

      it "should produce a hash of the report" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses report_format}
        hash["report_format"].should == 1
        hash["host"].should == "puppet.puppetlabs.vm"
        hash["time"].should == Time.parse("2010-07-22 12:19:46.169915 -07:00")
      end

      it "should include the logs" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash["logs"].should be_an(Array)

        logs = hash["logs"]
        logs.should == [{
          "line" => nil,
          "level" => "info",
          "tags" => ["info"],
          "file" => nil,
          "message" => "Caching catalog for puppet.puppetlabs.vm",
          "source" => "Puppet",
          "time" => Time.parse("2010-07-22 12:19:47.204207 -07:00"),
          "version" => "2.6.0"
        },
        {
          "line" => nil,
          "time" => Time.parse("2010-07-22 12:19:47.259181 -07:00"),
          "level" => "info",
          "tags" => ["info"],
          "file" => nil,
          "source" => "Puppet",
          "message" => "Applying configuration version '1279826342'",
          "version" => "2.6.0"
        },
        {
          "line" => 9,
          "time" => Time.parse("2010-07-22 12:19:47.360749 -07:00"),
          "level" => "notice",
          "tags" => ["notice", "exec", "node", "default", "class"],
          "file" => "/etc/puppet/manifests/site.pp",
          "source" => "/Stage[main]//Node[default]/Exec[/bin/true]/returns",
          "message" => "executed successfully",
          "version" => 1279826342
        },
        {
          "line" => 8,
          "time" => Time.parse("2010-07-22 12:19:48.921554 -07:00"),
          "level" => "notice",
          "tags" => ["notice", "service", "mysqld", "node", "default", "class"],
          "file" => "/etc/puppet/manifests/site.pp",
          "source" => "/Stage[main]//Node[default]/Service[mysqld]/ensure",
          "message" => "ensure changed 'stopped' to 'running'",
          "version" => 1279826342
        }]
      end

      it "should include the metrics" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash["metrics"].should be_a(Hash)
        metrics = hash["metrics"]
        metrics.should == {
          "time"=> {
            "service" => 1.555161,
            "schedule" => 0.001672,
            "config_retrieval" => 0.158488988876343,
            "filebucket" => 0.000237,
            "exec" => 0.100309
          },
          "resources"=> {
            "changed" => 2,
            "total" => 9,
            "out_of_sync" => 2
          },
          "events"=> {
            "total" => 2,
            "success" => 2
          },
          "changes"=> {
            "total" => 2
          }
        }
      end

      it "should include the resource statuses and events" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash["resource_statuses"].should be_a(Hash)
        resource_statuses = hash["resource_statuses"]
        resource_statuses.should == {
          "Schedule[monthly]" => {
            "skipped"            => nil,
            "line"               => nil,
            "change_count"       => 0,
            "time"               => Time.parse("2010-07-22 12:19:47.260865 -07:00"),
            "evaluation_time"    => 0.000432,
            "tags"               => [
              "schedule",
              "monthly"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Filebucket[puppet]" => {
            "skipped"            => nil,
            "line"               => nil,
            "change_count"       => 0,
            "time"               => Time.parse("2010-07-22 12:19:47.365218 -07:00"),
            "evaluation_time"    => 0.000237,
            "tags"               => [
              "filebucket",
              "puppet"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Service[mysqld]" => {
            "skipped"            => nil,
            "line"               => 8,
            "change_count"       => 1,
            "time"               => Time.parse("2010-07-22 12:19:47.367360 -07:00"),
            "evaluation_time"    => 1.555161,
            "tags"               => [
              "service",
              "mysqld",
              "node",
              "default",
              "class"
            ],
            "file"               => "/etc/puppet/manifests/site.pp",
            "events"             => [{
              "previous_value"     => :stopped,
              "desired_value"      => :running,
              "message"            => "ensure changed 'stopped' to 'running'",
              "name"               => "service_started",
              "property"           => "ensure",
              "status"             => "success",
              "time"               => Time.parse("2010-07-22 12:19:48.921431 -07:00")
            }],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Schedule[never]" => {
            "skipped"            => nil,
            "line"               => nil,
            "change_count"       => 0,
            "time"               => Time.parse("2010-07-22 12:19:47.365927 -07:00"),
            "evaluation_time"    => 0.000196,
            "tags"               => [
              "schedule",
              "never"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Schedule[weekly]" => {
            "skipped"            => nil,
            "line"               => nil,
            "change_count"       => 0,
            "time"               => Time.parse("2010-07-22 12:19:47.364377 -07:00"),
            "evaluation_time"    => 0.00033,
            "tags"               => [
            "schedule",
            "weekly"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Exec[/bin/true]" => {
            "skipped"            => nil,
            "line"               => 9,
            "change_count"       => 1,
            "time"               => Time.parse("2010-07-22 12:19:47.262652 -07:00"),
            "evaluation_time"    => 0.100309,
            "tags"               => [
              "exec",
              "node",
              "default",
              "class"
            ],
            "file"               => "/etc/puppet/manifests/site.pp",
            "events"             => [{
              "previous_value"     => :notrun,
              "desired_value"      => ["0"],
              "message"            => "executed successfully",
              "name"               => "executed_command",
              "property"           => "returns",
              "status"             => "success",
              "time"               => Time.parse("2010-07-22 12:19:47.360626 -07:00")
            }],
            "version"            => 1279826342,
            "failed"             => true
          },
          "Schedule[puppet]" => {
            "skipped"            => nil,
            "line"               => nil,
            "change_count"       => 0,
            "time"               => Time.parse("2010-07-22 12:19:48.923135 -07:00"),
            "evaluation_time"    => 0.000243,
            "tags"               => [
              "schedule",
              "puppet"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Schedule[daily]" => {
            "skipped"         => nil,
            "line"            => nil,
            "change_count"    => 0,
            "time"            => Time.parse("2010-07-22 12:19:47.366606 -07:00"),
            "evaluation_time" => 0.000216,
            "tags"            => [
              "schedule",
              "daily"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          },
          "Schedule[hourly]" => {
            "skipped"         => nil,
            "line"            => nil,
            "change_count"    => 0,
            "time"            => Time.parse("2010-07-22 12:19:47.261846 -07:00"),
            "evaluation_time" => 0.000255,
            "tags"            => [
              "schedule",
              "hourly"
            ],
            "file"               => nil,
            "events"             => [],
            "version"            => 1279826342,
            "failed"             => nil
          }
        }
      end
    end

    describe 'a format version 2 (puppet 2.6.5-2.7.11) report' do
      let(:report_file) { '02_failing.yaml' }

      it "should produce a hash of the report" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status}
        hash["report_format"].should == 2
        hash["host"].should == "localhost"
        hash["time"].should == Time.parse("2010-07-22 12:19:47.204207 -07:00")
      end
    end

    describe 'a format version 3 (puppet 2.7.13-3.2.4) report' do
      let(:report_file) { '03_failing.yaml' }

      it "should produce a hash of the report" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status environment}
        hash["report_format"].should == 3
        hash["host"].should == "localhost"
        hash["time"].should == Time.parse("2010-07-22 12:19:47.204207 -07:00")
        hash["environment"].should == "production"
      end
    end

   describe 'a format version 4 (puppet 3.3.0-4.3.2) report' do
      let(:report_file) { '04_failing.yaml' }

      it "should produce a hash of the report" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status environment transaction_uuid}
        hash["report_format"].should == 4
        hash["host"].should == "localhost"
        hash["time"].should == Time.parse("2010-07-22 12:19:47.204207 -07:00")
        hash["environment"].should == "production"
        hash["transaction_uuid"].should == "b2b7567c-696a-4250-8d74-e3c5030e1263"
      end

      it "should have resource_statuses that contain a containment_path" do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash["resource_statuses"].values.each do |resource_status|
          resource_status["containment_path"].should be_a(Array)
        end
      end

      it "should allow resource events that do not contain property previous_value desired_value or historical_value" do
        expect { ReportSanitizer.sanitize(raw_report) }.to_not raise_error
      end
    end

   describe 'a format version 5 (puppet 4.4.0-4.5.3) report' do
      let(:report_file) { '05_failing.yaml' }

      it 'should produce a hash of the report' do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status environment transaction_uuid catalog_uuid cached_catalog_status}
        hash['report_format'].should == 5
        hash['host'].should == 'report-test.example.com'
        hash['time'].should == Time.parse('2018-06-12 22:42:23.273615216 +02:00')
        hash['environment'].should == 'production'
        hash['transaction_uuid'].should == '439b4577-1b26-4313-91ea-3e2812d41d22'
        hash['catalog_uuid'].should == 'da1beb33-3775-4c12-88f5-78ad84a54988'
        hash['cached_catalog_status'].should == 'not_used'
      end
    end

    describe 'a format version 6 (puppet 4.6.0-4.10.x) report' do
      let(:report_file) { '06_failing.yaml' }

      it 'should produce a hash of the report' do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status environment transaction_uuid catalog_uuid cached_catalog_status noop noop_pending corrective_change master_used}
        hash['report_format'].should == 6
        hash['host'].should == 'report-test.example.com'
        hash['time'].should == Time.parse('2018-06-12 23:17:11.338306228 +02:00')
        hash['noop'].should == false
        hash['noop_pending'].should == false
        hash['corrective_change'].should == false
        hash['master_used'].should == nil
        resource_status = hash['resource_statuses']['Notify[hello world]']
        resource_status['corrective_change'].should == false
        event = resource_status['events'].first
        event['audited'].should == false
        event['corrective_change'].should == false
      end
    end

    describe 'a format version 7 (puppet 5.0.0-5.3.x) report' do
      let(:report_file) { '07_failing.yaml' }

      it 'should produce a hash of the report' do
        hash = ReportSanitizer.sanitize(raw_report)
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status environment transaction_uuid catalog_uuid cached_catalog_status noop noop_pending corrective_change master_used}
        hash['report_format'].should == 7
        hash['host'].should == 'report-test.example.com'
        hash['kind'].should == 'apply'
      end
    end

  end
end
