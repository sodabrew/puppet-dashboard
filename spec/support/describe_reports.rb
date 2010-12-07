module DescribeReports
  REPORTS_META = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'meta.yml')).with_indifferent_access

  # runs a set of specs for each report fixture categorized in
  # spec/fixtures/reports/meta.yml. It will provide a let accessor called
  # `report' for the current report and an `info' accessor for the meta info
  # for that report that can be used in the subject.
  #
  # Example:
  #
  #     describe_reports "#changed_resources?" do subject { report.changed_resources? } it { should
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

end
