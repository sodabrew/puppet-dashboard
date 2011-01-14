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
          "logs" => logs.map(&:to_hash),
          "metrics" => metrics.values.map(&:to_hash).inject({},&:merge)
        }
      end
    end

    class Event
      attr_reader :name, :property,
        :desired_value, :time,
        :status, :previous_value, :message

      def to_hash
        {
          "previous_value"     => previous_value,
          "desired_value"      => desired_value,
          "message"            => message,
          "name"               => name.to_s,
          "property"           => property,
          "status"             => status,
          "time"               => time
        }
      end
    end
  end

  module Util
    class Metric
      attr_reader :name, :values

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
      attr_reader :file, :level, :line, :message, :source, :tags, :time

      def to_hash
        {
          "file" => file,
          "level" => level.to_s,
          "line" => line,
          "message" => message,
          "source" => source,
          "tags" => tags,
          "time" => time
        }
      end
    end
  end

  module Resource
    class Status
      attr_reader :evaluation_time, :resource, :tags,
      :file, :events, :time, :line, :changed, :change_count,
      :skipped, :failed

      def to_hash
        {
          "evaluation_time" => evaluation_time,
          "file" => file,
          "line" => line,
          "tags" => tags,
          "time" => time,
          "change_count" => change_count || 0,
          "events" => events.map(&:to_hash),
          "skipped" => skipped,
          "failed" => failed,
        }
      end
    end
  end
end

module ReportExtensions #:nodoc:
  def self.extended(obj)
    case
    when obj.instance_variables.include?('@report_format')
      obj.extend ReportFormat2::Report
    when obj.instance_variables.include?("@resource_statuses")
      obj.extend ReportFormat1::Report
    else
      obj.extend ReportFormat0::Report
    end
  end

  module ReportFormat0
    module Report
      def self.extended(obj)
        obj.logs.each{|log| log.extend ReportFormat0::Util::Log} if obj.logs.respond_to?(:each)
      end

      def report_format
        0
      end
    end

    module Util
      module Log
        attr_reader :version

        def to_hash
          hash = super
          hash["version"] = version
          hash
        end
      end
    end
  end

  module ReportFormat1
    module Report
      def self.extended(obj)
        obj.logs.each{|log| log.extend ReportFormat1::Util::Log} if obj.logs.respond_to?(:each)
        obj.resource_statuses.each{|_, status| status.extend ReportFormat1::Resource::Status} if obj.resource_statuses.respond_to?(:each)
      end

      # Attributes in 2.6.x but not 0.25.x
      attr_reader :resource_statuses

      def to_hash
        hash = super
        hash["resource_statuses"] = {}
        resource_statuses.each do |key, value|
          hash["resource_statuses"][key] = value.to_hash
        end
        hash
      end

      def report_format
        1
      end
    end

    module Resource
      module Status
        attr_reader :version

        def to_hash
          hash = super
          hash["version"] = version
          hash
        end
      end
    end

    module Util
      module Log
        attr_reader :version

        def to_hash
          hash = super
          hash["version"] = version
          hash
        end
      end
    end
  end

  module ReportFormat2
    module Report
      attr_reader :report_format

      def self.extended(obj)
        obj.resource_statuses.each do |_, status| 
          status.extend ReportFormat2::Resource::Status
          status.events.each {|event| event.extend ReportFormat2::Transaction::Event}
        end if obj.resource_statuses
      end

      attr_reader :resource_statuses, :kind, :puppet_version, :configuration_version, :status

      def to_hash
        hash = super
        hash["resource_statuses"] = {}
        resource_statuses.each do |key, value|
          hash["resource_statuses"][key] = value.to_hash
        end
        hash["kind"] = kind
        hash["status"] = status
        hash["puppet_version"] = puppet_version
        hash["configuration_version"] = configuration_version
        hash
      end
    end

    module Resource
      module Status
        attr_reader :resource_type, :title, :out_of_sync_count

        def to_hash
          hash = super
          hash["resource_type"] = resource_type
          hash["out_of_sync_count"] = out_of_sync_count
          hash["title"] = title
          hash
        end
      end
    end

    module Transaction
      module Event
        attr_reader :audited, :historical_value

        def to_hash
          hash = super
          hash["audited"] = audited
          hash["historical_value"] = historical_value
          hash
        end
      end
    end
  end
end
