require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Puppet::Transaction::Report do
  extend DescribeReports

  describe "#metric_value" do
    let(:report) { YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'puppet25', '1_changed_0_failures.yml')) }

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

  describe "when making a hash" do
    describe "for a 0.25.x report" do
      before do
        @report = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'puppet25', '1_changed_0_failures.yml'))
        @report.extend(ReportExtensions)
      end

      it "should produce a hash of the report" do
        hash = @report.to_hash
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics report_format}
        hash["report_format"].should == 0
        hash["host"].should == "sample_node"
        hash["time"].should == Time.parse("2009-11-19 17:08:50.631428 -08:00")
      end

      it "should include the logs" do
        hash = @report.to_hash
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
        hash = @report.to_hash
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

    describe "for a format 1 report" do
      before do
        @yaml_filename = Rails.root.join('spec', 'fixtures', 'reports', 'puppet26', 'report_ok_service_started_ok.yaml')
        @report = YAML.load_file(@yaml_filename)
        @report.extend(ReportExtensions)
      end

      it "should fill in change_count=0 wherever a report is missing change_count attributes" do
        report_yaml = File.read(@yaml_filename)
        substitutions_performed = report_yaml.gsub!(/^ *change_count: [0-9]+\n/, '')
        substitutions_performed.should be_true
        @report = YAML.load(report_yaml)
        @report.extend(ReportExtensions)
        hash = @report.to_hash
        hash["resource_statuses"].values.each do |resource_status|
          resource_status["change_count"].should == 0
        end
      end

      it "should produce a hash of the report" do
        hash = @report.to_hash
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses report_format}
        hash["report_format"].should == 1
        hash["host"].should == "puppet.puppetlabs.vm"
        hash["time"].should == Time.parse("2010-07-22 12:19:46.169915 -07:00")
      end

      it "should include the logs" do
        hash = @report.to_hash
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
        hash = @report.to_hash
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
        hash = @report.to_hash
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

    describe "for a format 2 report" do
      before do
        report_yaml = <<HEREDOC
--- !ruby/object:Puppet::Transaction::Report
  host: localhost
  time: 2010-07-22 12:19:47.204207 -07:00
  logs: []
  metrics:
    time: !ruby/object:Puppet::Util::Metric
      name: time
      label: Time
      values:
        - - config_retrieval
          - Config retrieval
          - 0.25
        - - total
          - Total
          - 0.5
    resources: !ruby/object:Puppet::Util::Metric
      name: resources
      label: Resources
      values:
        - - failed
          - Failed
          - 1
        - - out_of_sync
          - Out of sync
          - 2
        - - changed
          - Changed
          - 3
        - - total
          - Total
          - 4
    events: !ruby/object:Puppet::Util::Metric
      name: events
      label: Events
      values:
        - - total
          - Total
          - 0
    changes: !ruby/object:Puppet::Util::Metric
      name: changes
      label: Changes
      values:
        - - total
          - Total
          - 0
  resource_statuses: {}
  configuration_version: 12345
  report_format: 2
  puppet_version: 2.6.5
  kind: apply
  status: unchanged
HEREDOC
        @report = YAML.load(report_yaml)
        @report.extend(ReportExtensions)
      end

      it "should produce a hash of the report" do
        hash = @report.to_hash
        hash.should be_a(Hash)
        hash.keys.should =~ %w{host time logs metrics resource_statuses kind configuration_version puppet_version report_format status}
        hash["report_format"].should == 2
        hash["host"].should == "localhost"
        hash["time"].should == Time.parse("2010-07-22 12:19:47.204207 -07:00")
      end
    end
  end
end
