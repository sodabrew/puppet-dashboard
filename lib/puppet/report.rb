# Simple data objects used to reconstitute reports from YAML. This way we don't
# have to load the full Puppet library, but it does mean that these must now be
# updated to handle changes in the Puppet implementation.
#
module Puppet #:nodoc:
  class Transaction
    class Report
      attr_reader :logs, :metrics, :host, :time
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

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} name: #{name.inspect}>"
      end
    end

    class Log
      attr_reader :file, :level, :line, :message, :source, :tags, :time, :version

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} #{"%6s" % level}: #{message.inspect}>"
      end
    end
  end
end
