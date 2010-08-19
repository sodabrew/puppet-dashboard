require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Status  do
  include ReportSupport

  describe ".by_interval" do
    context "when the interval is 1 day" do
      before do
        time = Time.now.beginning_of_day + 1.hours
        Report.generate!(:report => report_yaml_with(:time => time))

        time = Time.now.beginning_of_day - 1.hours
        Report.generate!(:report => report_yaml_with(:time => time))
      end

      it "should return reports for the correct day only" do
        Status.by_interval(:limit => 1).first.total.should == 1
      end
    end
  end
end
