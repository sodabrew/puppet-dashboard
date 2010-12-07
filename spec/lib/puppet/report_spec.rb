require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Puppet::Transaction::Report do
  extend DescribeReports

  describe "#metric_value" do
    let(:report) { YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'puppet25', '1_changed_0_failures.yml')) }

    describe "when the value exists" do
      subject { total = report.metric_value(:resources, :total) }
      it { should be_present }
    end

    describe "when the value does not exist" do
      subject { report.metric_value(:resources, :missing) }
      it { should be_nil }
    end

    describe "when the key does not exist" do
      subject { report.metric_value(:missing) }
      it { should be_nil }
    end
  end
end
