module ReportSupport
  REPORT_TEMPLATE = Rails.root.join('spec', 'fixtures', 'sample_report.yml.erb')

  def report_yaml_with(options={})
    template = File.read(REPORT_TEMPLATE)
    ERB.new(template).result(options.send(:binding))
  end
end
