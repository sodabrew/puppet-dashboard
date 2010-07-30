module DescribeReports
  REPORTS_META = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'meta.yml')).with_indifferent_access

  # runs a set of specs for each report fixture categorized in
  # spec/fixtures/reports/meta.yml. It will provide a let accessor called
  # `report' for the current report and an `info' accessor for the meta info
  # for that report that can be used in the subject.
  #
  # Example:
  #
  #     describe_reports "#changed?" do subject { report.changed? } it { should
  #     == info[:changed] > 0} end
  #
  def describe_reports(*args, &block)
    options = {}
    options = args.pop if Hash === args.last

    desc = ""
    meta = REPORTS_META

    if options[:version]
      desc = " Puppet #{options[:version]}"
      meta = REPORTS_META.select{|_, info| info[:version] == options[:version]}
    end

    describe *args do
      meta.each do |file, info|
        describe file + desc do
          let(:report) { report_from_yaml(file) }
          let(:info) { info }
          instance_eval &block
        end
      end
    end
  end

  def report_from_yaml(path)
    report_model_from_yaml(path).report
  end

  def report_model_from_yaml(path)
    report_root = Rails.root.join('spec', 'fixtures', 'reports')
    report_file = report_root.join(path)
    raise "No such file #{report_file}" unless File.exists?(report_file)
    report_yaml = File.read(report_file)
    Report.new(:report => report_yaml)
  end

end
