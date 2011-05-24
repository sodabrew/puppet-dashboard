#!/usr/bin/env ruby

module Puppet; end
module Puppet::Resource; end
class Puppet::Transaction; end
module Puppet::Util; end

# http://projects.puppetlabs.com/projects/puppet/wiki/Report_Format_2
class Puppet::Transaction::Report
  attr_accessor :host, :time, :logs, :metrics, :resource_statuses,
    :configuration_version, :report_format, :puppet_version, :kind, :status

  def self.generate(options)
    Puppet::Transaction::Report.new.tap do |report|
      report.host = options[:hostname]
      report.time = DataGenerator.generate_time(options[:time_offset])
      report.logs = []
      report.metrics = {}
      report.resource_statuses = {}
      report.configuration_version = Time.now.to_i
      report.report_format = 2
      report.puppet_version = "2.6.5"
      report.kind = "apply"

      options[:num_statuses].times do
        resource_status = DataGenerator.generate_resource_status(report, options)
        report.resource_statuses[resource_status.resource] = resource_status
      end

      report.status = report.compute_status
    end
  end

  def compute_status
    if resource_statuses.values.any? {|res| res.failed}
      "failed"
    elsif resource_statuses.values.any? {|res| res.changed}
      "changed"
    else
      "unchanged"
    end
  end
end
class Puppet::Util::Log
  attr_accessor :file, :line, :level, :message, :source, :tags, :time
end
class Puppet::Util::Metric
  attr_accessor :name, :label, :values
end
class Puppet::Resource::Status
  attr_accessor :resource_type, :title, :resource, :file, :line,
    :evaluation_time, :change_count, :out_of_sync_count, :tags, :time, :events,
    :out_of_sync, :changed, :skipped, :failed

  def self.generate(report, options)
    Puppet::Resource::Status.new.tap do |rs|
      rs.resource_type     = "File"
      rs.title             = File.join("/", (1..(rand(5)+2)).map {DataGenerator.generate_word})
      rs.resource          = "#{rs.resource_type}[#{rs.title}]"
      rs.file              = "/etc/puppet/manifests/site.pp"
      rs.line              = rand(250) + 1
      rs.evaluation_time   = Time.now.to_f % 1 + rand(3)
      rs.change_count      = rand(100) < 80 ? 0 : rand(5)+1
      rs.out_of_sync_count = rs.change_count
      rs.tags              = ["node", "class", rs.resource_type.downcase, rs.title.downcase, report.host].sort
      rs.time              = report.time
      rs.events            = []
      rs.out_of_sync       = rs.out_of_sync_count > 0
      rs.changed           = rs.change_count > 0
      rs.skipped           = false
      rs.failed            = rs.change_count > 0 && rand(100) < 10

      options[:num_events].times do
        event = DataGenerator.generate_resource_event(rs)
        rs.events << event
      end

    end
  end
end
class Puppet::Transaction::Event
  attr_accessor :audited, :property, :previous_value, :desired_value,
    :historical_value, :message, :name, :status, :time

  def self.generate(resource_status)
    Puppet::Transaction::Event.new.tap do |event|
      event.audited          = false
      event.property         = "mode"
      event.previous_value   = 644
      event.desired_value    = 777
      event.historical_value = 666
      event.message          = "Updated file mode"
      event.name             = "mode"
      event.status           = "success"
      event.time             = resource_status.time
    end
  end
end

module DataGenerator
  def self.generate_reports(options)
    Puppet::Transaction::Report.generate(options)
  end

  def self.generate_resource_event(resource_status)
    Puppet::Transaction::Event.generate(resource_status)
  end

  def self.generate_resource_status(report, options)
    Puppet::Resource::Status.generate(report, options)
  end

  def self.generate_hostname
    @domain ||= generate_word
    @ext ||= ["net", "org", "com", "co.uk"].shuffle.first

    host = @domain
    host = generate_word until host != @domain
    "#{host}.#{@domain}.#{@ext}"
  end

  def self.generate_time(offset=nil)
    time = Time.now
    time -= 1.hour if rand(100) < 5
    time -= offset.day if offset
    time
  end

  def self.generate_word
    words[rand(words.length)]
  end

  private
  def self.words
    @words ||= File.new('/usr/share/dict/words').lines.map(&:chomp).reject do |w|
      w.length < 6 or w =~ /[A-Z]|(.)\1/
    end
  end
end
