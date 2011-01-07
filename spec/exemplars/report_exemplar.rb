class Report
  generator_for :host, :start => "Report_host.001"
  generator_for :time, Time.now
  generator_for :status, "failed"
end
