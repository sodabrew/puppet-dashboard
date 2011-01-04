require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe ReportTransformer do
  describe "when given a version 0 report" do
    before do
      report_object = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'puppet25', '1_changed_0_failures.yml'))
      report_object.extend(ReportExtensions)
      @report = report_object.to_hash
    end

    it "should run the appropriate transformations" do
      ReportTransformer::ZeroToOne.expects(:transform).with(@report)
      ReportTransformer::OneToTwo.expects(:transform).with(@report)
      report = ReportTransformer.apply(@report)
    end
  end

  describe "when given a version 1 report" do
    before do
      report_object = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'puppet26', 'report_ok_service_started_ok.yaml'))
      report_object.extend(ReportExtensions)
      @report = report_object.to_hash
    end

    it "should run the appropriate transformations" do
      ReportTransformer::ZeroToOne.expects(:transform).with(@report).never
      ReportTransformer::OneToTwo.expects(:transform).with(@report)
      report = ReportTransformer.apply(@report)
    end
  end

  describe "when converting from version 0 to version 1" do
    before do
      @report = {"report_format" => 0, "logs" => []}
    end
    it "should add an empty array for resource_statuses" do
      report = ReportTransformer::ZeroToOne.apply(@report)
      report["resource_statuses"].should == []
    end
  end

  describe "when converting from version 1 to version 2" do
    before do
      report_object = YAML.load_file(Rails.root.join('spec', 'fixtures', 'reports', 'puppet26', 'report_ok_service_started_ok.yaml'))
      report_object.extend(ReportExtensions)
      @report = report_object.to_hash
    end

    it "should add a total time metric if one doesn't exist" do
      report = ReportTransformer::OneToTwo.apply(@report)
      report["metrics"]["time"]["total"].round(2).should == 1.82
    end

    it "should not add a total time metric if one does exist" do
      @report["metrics"]["time"]["total"] = 12.0
      report = ReportTransformer::OneToTwo.apply(@report)
      report["metrics"]["time"]["total"].round(2).should == 12
    end

    it "should be able to handle a report with no metrics" do
      @report["metrics"] = {}
      report = ReportTransformer::OneToTwo.apply(@report)
      report["metrics"].should == {}
      report["status"].should == "failed"
    end

    it "should set the status to 'failed' if there were failures" do
      @report["metrics"]["resources"]["failed"] = 5
      report = ReportTransformer::OneToTwo.apply(@report)
      @report["status"].should == "failed"
    end

    it "should set the status to 'changed' if there were changes" do
      @report["metrics"]["resources"]["failed"] = 0
      @report["metrics"]["changes"]["total"] = 5
      report = ReportTransformer::OneToTwo.apply(@report)
      @report["status"].should == "changed"
    end

    it "should set the status to 'unchanged' if there were no changes" do
      @report["metrics"]["resources"]["failed"] = 0
      @report["metrics"]["changes"]["total"] = 0
      report = ReportTransformer::OneToTwo.apply(@report)
      @report["status"].should == "unchanged"
    end
  end
end
