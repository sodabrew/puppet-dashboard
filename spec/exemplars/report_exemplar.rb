class Report
  generator_for :report do
    YAML.load_file("#{RAILS_ROOT}/spec/fixtures/sample_report.yml")
  end
end
