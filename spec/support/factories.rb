# TODO figure out how to add these to exemplar.

class Report
  def self.generate_for(node, time=Time.now, status='unchanged')
    report = Report.new
    report.time = time
    report.status = status
    report.host = node
    report.node = node
    report.stubs(:process_report => true)
    report.stubs(
      :failed? => report.status == 'failed',
      :total_resources => 1,
      :failed_resources => report.status == 'failed' ? 1 : 0,
      :failed_restarts => 0,
      :skipped_resources => 0,
      :config_retrieval_time => 0.1,
      :total_time => 0.1
    )
    report.save!
    return report
  end
end
