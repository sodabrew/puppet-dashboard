# TODO figure out how to add these to exemplar.

class Report
  def self.generate_for(node, time = Time.now, success = true)
    report = Report.new
    report.time = time
    report.success = success
    report.host = node
    report.node = node
    report.stubs(:process_report => true, :report_contains_metrics => true)
    report.save!
    return report
  end
end
