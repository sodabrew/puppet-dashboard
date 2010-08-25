# TODO figure out how to add these to exemplar.

class Report
  def self.generate_for(node, time=Time.now, success=true)
    report = Report.new
    report.time = time
    report.success = success
    report.host = node
    report.node = node
    report.stubs(:process_report => true, :report_contains_metrics => true)
    report.save!
    report.stubs(
      :failed? => !success,
      :total_resources => 1,
      :failed_resources => 0,
      :failed_restarts => 0,
      :skipped_resources => 0,
      :config_retrieval_time => 0.1,
      :total_time => 0.1
    )
    return report
  end
end
