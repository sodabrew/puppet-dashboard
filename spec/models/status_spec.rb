require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Status  do
  include ReportSupport

  describe ".by_interval" do
    context "when the interval is 1 day" do
      before :each do
        Time.zone = 'Pacific Time (US & Canada)'

        time = Time.zone.parse("2009-11-12 00:01 PST")
        Report.generate!(:time => time)

        time = Time.zone.parse("2009-11-11 23:59 PST")
        Report.generate!(:time => time)

        time = Time.zone.parse("2009-11-10 23:59 PST")
        Report.generate!(:time => time)
        Report.generate!(:time => time - 10)
      end

      it "should return reports for the correct day only" do
        Status.by_interval(:limit => 1, :start => Time.zone.parse("2009-11-11 00:00 PST")).
          map(&:start).should == [Time.zone.parse("2009-11-11 00:00 PST")]

        Status.by_interval(:limit => 1, :start => Time.zone.parse("2009-11-12 00:00 PST")).
          map(&:start).should == [Time.zone.parse("2009-11-12 00:00 PST")]

        Status.by_interval(:limit => 1, :start => Time.zone.parse("2009-11-10 00:00 PST")).map(&:total).should == [2]
      end

      it "should return reports after the start time" do
        Status.by_interval(:start => Time.zone.parse("2009-11-11 00:00 PST")).
          map(&:start).should == ["2009-11-11 00:00 PST", "2009-11-12 00:00 PST"].map {|time| Time.zone.parse time}
      end
    end
  end

  describe ".within_daily_run_history" do
    context "when the daily_run_history_length is 1 day" do
      before :each do
        time = Time.zone.now.beginning_of_day + 1.hours
        Report.generate!(:time => time)

        time = Time.zone.now.beginning_of_day - 1.hours
        Report.generate!(:time => time)

        SETTINGS.stubs(:daily_run_history_length).returns(1)
      end

      it "should return reports for the correct day only" do
        Status.within_daily_run_history.first.total.should == 1
      end
    end

    context "when the daily_run_history_length is 0 days" do
      before :each do
        time = Time.zone.now.beginning_of_day + 1.hours
        Report.generate!(:time => time)

        time = Time.zone.now.beginning_of_day - 1.hours
        Report.generate!(:time => time)

        SETTINGS.stubs(:daily_run_history_length).returns(0)
      end

      it "should not return any history" do
        Status.within_daily_run_history.should == []
      end
    end
  end

end
