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
    end

    class Event
      attr_reader :name, :default_log_level, :property, :line, :resource,
        :desired_value, :time, :tags, :version, :source_description, :file,
        :status, :previous_value, :message
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
    end

    class Log
      attr_reader :file, :level, :line, :message, :source, :tags, :time, :version
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

      # 0.25 reports don't have kind but this makes the interface more consistent
      def kind
        nil
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
    end

    module Resource
      module Status
        attr_reader :source_description, :evaluation_time, :resource, :tags,
          :file, :events, :time, :line, :version, :changed, :change_count,
          :out_of_sync
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
