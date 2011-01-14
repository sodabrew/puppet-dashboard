class ReportTransformer
  def self.transformations
    [ZeroToOne, OneToTwo]
  end

  def self.apply(report)
    transformations.inject(report) do |r,transformation|
      transformation.apply(r)
    end
    # report_format will always be the current format at this point, so we don't need it
    report.delete("report_format")
    report
  end
end

class ReportTransformer::ReportTransformation
  def self.apply(report)
    return report if report["report_format"] >= version

    transform(report)

    report["report_format"] = version
    report
  end
end

class ReportTransformer::ZeroToOne < ReportTransformer::ReportTransformation
  def self.version
    1
  end

  def self.transform(report)
    report["resource_statuses"] = {}
    report["puppet_version"] = "0.25.x"
    report["logs"].each do |log|
      log["version"] ||= log["source"] == "Puppet" ? "0.25.x" : nil
    end
    report
  end
end

class ReportTransformer::OneToTwo < ReportTransformer::ReportTransformation
  def self.version
    2
  end

  def self.transform(report)
    report["metrics"].keys.each do |metric_category|
      new_metrics = {}
      report["metrics"][metric_category].each do |metric_name, value|
        new_metrics[metric_name.to_s] = value
      end
      report["metrics"][metric_category] = new_metrics
    end
    if report["metrics"]["time"] and !report["metrics"]["time"]["total"]
      report["metrics"]["time"]["total"] = report["metrics"]["time"].values.sum
    end

    report["status"] = case
      when has_no_metrics?(report) || failed_resources?(report)
        'failed'
      when changed_resources?(report)
        'changed'
      else
        'unchanged'
      end
    report["configuration_version"] = configuration_version_from_resource_statuses(report) || configuration_version_from_log_objects(report) || configuration_version_from_log_message(report)
    report["kind"] = "apply"
    report["puppet_version"] ||= puppet_version(report) # If it started as a v0 report, we've already filled in puppet_version
    report["resource_statuses"].each do |key, resource_status|
      key =~ /^(.+?)\[(.+)\]$/
      resource_status["resource_type"], resource_status["title"] = $1, $2
      resource_status["skipped"] ||= false # ensure that we represent falsehood as "false", not "nil"
      resource_status["out_of_sync_count"] = resource_status["change_count"]
      resource_status["failed"] ||= false
      resource_status["events"].each do |event|
        event["audited"] = event["status"] == "audit"
        if event["audited"]
          event["historical_value"] = event["desired_value"]
          event["desired_value"] = nil
        else
          event["historical_value"] = nil
        end
      end
      resource_status.delete("version")
    end
    report["logs"].each do |log|
      log.delete("version")
    end
    report
  end

  def self.has_no_metrics?(report)
    report["metrics"].empty?
  end

  def self.failed_resources?(report)
    if report["metrics"]["resources"] and report["metrics"]["resources"]["failed"]
      report["metrics"]["resources"]["failed"] > 0
    else
      false
    end
  end

  def self.changed_resources?(report)
    if report["metrics"]["changes"] and report["metrics"]["changes"]["total"]
      report["metrics"]["changes"]["total"] > 0
    else
      false
    end
  end

  def self.puppet_version(report)
    report["logs"].each do |log|
      if log["version"] and log["source"] == "Puppet"
        return log["version"]
      end
    end
    "2.6.x"
  end

  def self.configuration_version_from_resource_statuses(report)
    report["resource_statuses"].values.each do |resource_status|
      return resource_status["version"].to_s if resource_status["version"]
    end
    nil
  end

  def self.configuration_version_from_log_objects(report)
    report["logs"].each do |log|
      if log["version"] and log["source"] != "Puppet"
        return log["version"].to_s
      end
    end
    nil
  end

  def self.configuration_version_from_log_message(report)
    report["logs"].each do |log|
      if log["message"] =~ /^Applying configuration version '(.*)'$/
        return $1
      end
    end
    nil
  end
end
