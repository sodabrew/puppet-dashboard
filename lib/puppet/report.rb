# Simple data objects used to reconstitute reports from YAML. This way we don't
# have to load the full Puppet library, but it does mean that these must now be
# updated to handle changes in the Puppet implementation.
#
module Puppet #:nodoc:
  class Transaction
    class Report
      attr_reader :logs, :metrics, :host, :time

      # Returns the metric value at the key found by traversing the metrics hash
      # tree. Returns nil if any intermediary results are nil.
      #
      def metric_value(*keys)
        return nil unless metrics
        result = metrics
        keys.each do |key|
          result = result[key.to_sym] || result[key.to_s]
          break unless result
        end
        result
      end

      def to_hash
        hash = {
          "report_format" => report_format,
          "host" => host,
          "time" => time,
          "kind" => kind,
          "puppet_version" => puppet_version,
          "configuration_version" => configuration_version,
          "logs" => logs.map(&:to_hash),
          "metrics" => metrics.values.map(&:to_hash).inject({},&:merge)
        }
      end

      def configuration_version_from_log_objects
        logs.each do |log|
          if log.version and log.source != "Puppet"
            return log.version.to_s
          end
        end
        nil
      end

      def configuration_version_from_log_message
        logs.each do |log|
          if log.message =~ /^Applying configuration version '(.*)'$/
            return $1
          end
        end
        nil
      end
    end

    class Event
      attr_reader :name, :default_log_level, :property, :line, :resource,
        :desired_value, :time, :tags, :version, :source_description, :file,
        :status, :previous_value, :message

      def to_hash
        {
          "previous_value"     => previous_value,
          "desired_value"      => desired_value,
          "message"            => message,
          "name"               => name.to_s,
          "property"           => property,
          "source_description" => source_description,
          "status"             => status,
          "tags"               => tags,
          "time"               => time
        }
      end
    end
  end

  module Util
    class Metric
      attr_reader :type, :name, :values, :label

      # Return a specific value
      def [](name)
        value = @values.find { |v| v[0] == name }
        value && value[2]
      end

      def to_hash
        {
          name.to_s => values.map {|key,_,value| {key.to_s => value} }.inject({},&:merge)
        }
      end
    end

    class Log
      attr_reader :file, :level, :line, :message, :source, :tags, :time, :version

      def to_hash
        {
          "file" => file,
          "level" => level.to_s,
          "line" => line,
          "message" => message,
          "source" => source,
          "tags" => tags,
          "time" => time,
        }
      end
    end
  end

  module Resource
    class Status
    end
  end
end

module ReportExtensions #:nodoc:
  def self.extended(obj)
    case
    when obj.instance_variables.include?("@resource_statuses")
      obj.extend Puppet26::Report
    else
      obj.extend Puppet25::Report
    end
  end

  module Puppet25
    module Report
      def self.extended(obj)
        obj.logs.each{|log| log.extend Puppet25::Util::Log} if obj.logs.respond_to?(:each)
        obj.metrics.each{|_, metric| metric.extend Puppet25::Util::Metric} if obj.metrics.respond_to?(:each)
      end

      # 0.25 reports don't have resource statuses, but returning an empty list
      # here makes the interface consistent with 2.6
      def resource_statuses
        []
      end

      def kind
        "apply"
      end

      def report_format
        0
      end

      def puppet_version
        "0.25.x"
      end

      def configuration_version
        configuration_version_from_log_objects || configuration_version_from_log_message
      end
    end

    module Util
      module Metric
      end

      module Log
      end
    end
  end

  module Puppet26
    module Report
      def self.extended(obj)
        obj.logs.each{|log| log.extend Puppet26::Util::Log} if obj.logs.respond_to?(:each)
        obj.metrics.each{|_, metric| metric.extend Puppet26::Util::Metric} if obj.metrics.respond_to?(:each)
        obj.resource_statuses.each{|_, status| status.extend Puppet26::Resource::Status} if obj.resource_statuses.respond_to?(:each)
      end

      # Attributes in 2.6.x but not 0.25.x
      attr_reader :external_times, :resource_statuses, :kind

      def to_hash
        hash = super
        hash["resource_statuses"] = resource_statuses.values.map(&:to_hash)
        hash
      end

      def kind
        "apply"
      end

      def report_format
        1
      end

      def puppet_version
        logs.each do |log|
          if log.version and log.source == "Puppet"
            return log.version
          end
        end
        "2.6.x"
      end

      def configuration_version
        configuration_version_from_resource_statuses || configuration_version_from_log_objects || configuration_version_from_log_message 
      end

      def configuration_version_from_resource_statuses
        resource_statuses.values.each do |resource_status|
          return resource_status.version.to_s if resource_status.version
        end
        nil
      end
    end

    module Resource
      module Status
        attr_reader :source_description, :evaluation_time, :resource, :tags,
          :file, :events, :time, :line, :version, :changed, :change_count,
          :out_of_sync

        def to_hash
          resource =~ /^(.+?)\[(.+)\]$/
          resource_type, title = $1, $2
          {
            "resource_type" => resource_type,
            "title" => title,
            "evaluation_time" => evaluation_time,
            "file" => file,
            "line" => line,
            "source_description" => source_description,
            "tags" => tags,
            "time" => time,
            "change_count" => change_count || 0,
            "out_of_sync" => out_of_sync,
            "events" => events.map(&:to_hash)
          }
        end
      end
    end

    module Util
      module Metric
      end

      module Log
      end
    end
  end
end
