# Conversion calasses for converting data deserialized from puppet reports
# using safe_yaml into structures expected by the model code.
# Note that this must be updated whenever any of those changes.
#
# Report Format Docs:
# https://github.com/puppetlabs/puppet-docs/blob/master/source/_includes/reportformat
#
module ReportSanitizer #:nodoc:
  class << self
    def sanitize(raw)
      case
        when raw.include?('report_format')
          case raw['report_format']
            when 2
              format2sanitizer.sanitize(raw)
            when 3
              format3sanitizer.sanitize(raw)
            when 4
              format4sanitizer.sanitize(raw)
            when 5
              format5sanitizer.sanitize(raw)
            when 6
              format6sanitizer.sanitize(raw)
            else
              format7sanitizer.sanitize(raw)
          end
        when raw.include?('resource_statuses')
          format1sanitizer.sanitize(raw)
        else
          format0sanitizer.sanitize(raw)
      end
    end

    private

    def format0sanitizer()
      @format0sanitizer ||= ReportSanitizer::FormatVersion0.new
    end

    def format1sanitizer()
      @format1sanitizer ||= ReportSanitizer::FormatVersion1.new
    end

    def format2sanitizer()
      @format2sanitizer ||= ReportSanitizer::FormatVersion2.new
    end

    def format3sanitizer()
      @format3sanitizer ||= ReportSanitizer::FormatVersion3.new
    end

    def format4sanitizer()
      @format4sanitizer ||= ReportSanitizer::FormatVersion4.new
    end

    def format5sanitizer()
      @format5sanitizer ||= ReportSanitizer::FormatVersion5.new
    end

    def format6sanitizer()
      @format6sanitizer ||= ReportSanitizer::FormatVersion6.new
    end

    def format7sanitizer()
      @format7sanitizer ||= ReportSanitizer::FormatVersion7.new
    end
  end

  module Util
    class << self
      def verify_attributes(raw, names)
        names.each do |n|
          raise ArgumentError, "required attribute not present: #{n}" unless raw.include?(n)
        end
      end

      def copy_attributes(sanitized, raw, names)
        names.each do |n|
          sanitized[n] = raw[n]
        end
        sanitized
      end
    end
  end

  class Base
    def initialize(
      log_sanitizer    = LogSanitizer.new,
      metric_sanitizer = MetricSanitizer.new
    )
      @log_sanitizer    = log_sanitizer
      @metric_sanitizer = metric_sanitizer
    end

    def sanitize(raw)
      Util.verify_attributes(raw, %w[host time logs metrics])
      sanitized = {
        'report_format' => report_format(raw)
      }
      Util.copy_attributes(sanitized, raw, %w[host time])
      sanitized['logs']    = raw['logs'].map { |l| @log_sanitizer.sanitize(l) }
      sanitized['metrics'] = raw['metrics'].values.map { |m| @metric_sanitizer.sanitize(m) }.inject({},&:merge)
      sanitized
    end

    class LogSanitizer
      def sanitize(raw)
        Util.verify_attributes(raw, %w[message source tags time level])
        sanitized = Util.copy_attributes({}, raw, %w[file line message source tags time])
        sanitized['level'] = raw['level'].to_s
        sanitized
      end
    end

    class VersionLogSanitizer < LogSanitizer
      def sanitize(raw)
        sanitized = super
        Util.copy_attributes(sanitized, raw, %w[version])
      end
    end

    class MetricSanitizer
      def sanitize(raw)
        Util.verify_attributes(raw, %w[name values])
        {
          raw['name'].to_s => raw['values'].map { |k,_,v| { k.to_s => v } }.inject({},&:merge)
        }
      end
    end

    class StatusSanitizer
      def initialize(event_sanitizer = EventSanitizer.new)
        @event_sanitizer = event_sanitizer
      end

      def sanitize(raw)
        Util.verify_attributes(raw, %w[tags time events])
        sanitized = Util.copy_attributes({}, raw, %w[evaluation_time file line tags time change_count skipped failed])
        sanitized['change_count'] ||= 0
        sanitized['events']         = raw['events'].map { |e| @event_sanitizer.sanitize(e) }
        sanitized
      end

      class EventSanitizer
        def sanitize(raw)
          Util.verify_attributes(raw, %w[previous_value desired_value message property status time])

          sanitized = {}

          if raw['name']
            sanitized['name'] = raw['name'].to_s
          end

          Util.copy_attributes(sanitized, raw, %w[previous_value desired_value message property status time])
        end
      end
    end
  end

  # format version 0 was used by puppet 0.25.x
  class FormatVersion0 < Base
    def initialize(
      log_sanitizer    = VersionLogSanitizer.new,
      metric_sanitizer = MetricSanitizer.new
    )
      super(log_sanitizer, metric_sanitizer)
    end

    def report_format(raw)
      0
    end
  end

  # format version 1 was used by puppet 2.6.0-2.6.4
  class FormatVersion1 < Base
    def initialize(
      log_sanitizer    = VersionLogSanitizer.new,
      metric_sanitizer = MetricSanitizer.new,
      status_sanitizer = VersionStatusSanitizer.new
    )
      super(log_sanitizer, metric_sanitizer)
      @status_sanitizer = status_sanitizer
    end

    def report_format(raw)
      1
    end

    def sanitize(raw)
      sanitized = super
      Util.verify_attributes(raw, %w[resource_statuses])
      sanitized['resource_statuses'] = resource_statuses = {}
      raw['resource_statuses'].each do |key, value|
        resource_statuses[key] = @status_sanitizer.sanitize(value)
      end
      sanitized
    end

    class VersionStatusSanitizer < StatusSanitizer
      def sanitize(raw)
        sanitized = super
        Util.verify_attributes(raw, %w[version])
        Util.copy_attributes(sanitized, raw, %w[version])
      end
    end
  end

  # format version 2 was used by puppet 2.6.5-2.7.11
  class FormatVersion2 < FormatVersion1
    def initialize(
      log_sanitizer    = LogSanitizer.new,
      metric_sanitizer = MetricSanitizer.new,
      status_sanitizer = ExtendedStatusSanitizer.new
    )
      super(log_sanitizer, metric_sanitizer, status_sanitizer)
    end

    def report_format(raw)
      raw['report_format']
    end

    def sanitize(raw)
      sanitized = super
      Util.verify_attributes(raw, %w[kind status puppet_version configuration_version])
      Util.copy_attributes(sanitized, raw, %w[kind status puppet_version configuration_version])
    end

    class ExtendedStatusSanitizer < StatusSanitizer
      def initialize(event_sanitizer = ExtendedEventSanitizer.new)
        super(event_sanitizer)
      end

      def sanitize(raw)
        sanitized = super
        Util.verify_attributes(raw, %w[resource_type out_of_sync_count title])
        Util.copy_attributes(sanitized, raw, %w[resource_type out_of_sync_count title])
      end

      class ExtendedEventSanitizer < EventSanitizer
        def sanitize(raw)
          sanitized = super
          Util.verify_attributes(raw, %w[audited historical_value])
          Util.copy_attributes(sanitized, raw, %w[audited historical_value])
        end
      end
    end
  end

  # format version 3 was used by puppet 2.7.13-3.2.4
  class FormatVersion3 < FormatVersion2
    def sanitize(raw)
      sanitized = super
      Util.verify_attributes(raw, %w[kind status puppet_version configuration_version environment])
      Util.copy_attributes(sanitized, raw, %w[kind status puppet_version configuration_version environment])
    end
  end

  # format version 4 is used by puppet 3.3.0-4.3.2
  class FormatVersion4 < FormatVersion3
    def initialize(
      log_sanitizer    = FormatVersion4LogSanitizer.new,
      metric_sanitizer = MetricSanitizer.new,
      status_sanitizer = FormatVersion4StatusSanitizer.new
    )
      super(log_sanitizer, metric_sanitizer, status_sanitizer)
    end

    def sanitize(raw)
      sanitized = super
      Util.verify_attributes(raw, %w[kind status puppet_version configuration_version environment transaction_uuid])
      Util.copy_attributes(sanitized, raw, %w[kind status puppet_version configuration_version environment transaction_uuid])
    end

    class FormatVersion4LogSanitizer < LogSanitizer
      def sanitize(raw)
        sanitized = super
        unless sanitized['tags'].is_a?(Array)
          sanitized['tags'] = raw['tags']['hash'].keys
        end
        sanitized
      end
    end

    class FormatVersion4StatusSanitizer < ExtendedStatusSanitizer
      def initialize(event_sanitizer = FormatVersion4EventSanitizer.new)
        super(event_sanitizer)
      end

      def sanitize(raw)
        sanitized = super
        Util.verify_attributes(raw, %w[containment_path])
        Util.copy_attributes(sanitized, raw, %w[containment_path])

        unless sanitized['tags'].is_a?(Array)
          sanitized['tags'] = raw['tags']['hash'].keys
        end
        sanitized
      end

      class FormatVersion4EventSanitizer < ExtendedEventSanitizer
        def sanitize(raw)
          Util.verify_attributes(raw, %w[message status time audited])

          sanitized = {}

          if raw['name']
            sanitized['name'] = raw['name'].to_s
          end

          Util.copy_attributes(sanitized, raw, %w[previous_value desired_value message property status time audited historical_value])
        end
      end
    end
  end

  class FormatVersion5 < FormatVersion4
    def sanitize(raw)
      sanitized = super
      Util.verify_attributes(raw, %w[catalog_uuid cached_catalog_status])
      Util.copy_attributes(sanitized, raw, %w[catalog_uuid cached_catalog_status])
    end
  end

  class FormatVersion6 < FormatVersion5
    def initialize(
      log_sanitizer    = FormatVersion4LogSanitizer.new,
      metric_sanitizer = MetricSanitizer.new,
      status_sanitizer = FormatVersion5StatusSanitizer.new
    )
      super(log_sanitizer, metric_sanitizer, status_sanitizer)
    end

    def sanitize(raw)
      sanitized = super
      Util.verify_attributes(raw, %w[noop noop_pending corrective_change master_used])
      Util.copy_attributes(sanitized, raw, %w[noop noop_pending corrective_change master_used])
    end

    class FormatVersion5StatusSanitizer < FormatVersion4StatusSanitizer
      def initialize(event_sanitizer = FormatVersion5EventSanitizer.new)
        super(event_sanitizer)
      end

      def sanitize(raw)
        sanitized = super
        Util.verify_attributes(raw, %w[corrective_change])
        Util.copy_attributes(sanitized, raw, %w[corrective_change])
      end

      class FormatVersion5EventSanitizer < FormatVersion4EventSanitizer
        def sanitize(raw)
          sanitized = super
          Util.verify_attributes(raw, %w[corrective_change redacted])
          Util.copy_attributes(sanitized, raw, %w[corrective_change redacted])
        end
      end
    end
  end

  class FormatVersion7 < FormatVersion6
    def sanitize(raw)
      raw['kind'] = 'apply'
      raw['master_used'] ||= nil
      super
    end
  end

end
