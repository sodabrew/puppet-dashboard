require 'spec_helper'

describe Status  do
  include ReportSupport

  describe ".get_utc_boundaries_ending" do
    it "should not skip days near a daylight savings time boundary" do
      Time.zone = 'Pacific Time (US & Canada)'

      Status.get_utc_boundaries_ending(Time.zone.parse("2011-03-14 00:30:00 -0700"), 4).should == [
        Time.zone.parse("Mon, 14 Mar 2011 00:00:00 PDT -07:00"),
        Time.zone.parse("Sun, 13 Mar 2011 00:00:00 PST -08:00"),
        Time.zone.parse("Sat, 12 Mar 2011 00:00:00 PST -08:00"),
        Time.zone.parse("Fri, 11 Mar 2011 00:00:00 PST -08:00"),
      ]
    end

    it "should not consider DST when in a timezone without it" do
      Time.zone = 'Tokyo'

      Status.get_utc_boundaries_ending(Time.zone.parse("2011-03-14 00:30:00 +0900"), 4).should == [
        Time.zone.parse("Mon, 14 Mar 2011 00:00:00 +09:00"),
        Time.zone.parse("Sun, 13 Mar 2011 00:00:00 +09:00"),
        Time.zone.parse("Sat, 12 Mar 2011 00:00:00 +09:00"),
        Time.zone.parse("Fri, 11 Mar 2011 00:00:00 +09:00"),
      ]
    end
  end

  describe ".by_interval" do
    describe "when the local timezone is one that uses DST" do
      before :each do
        Time.zone = 'Pacific Time (US & Canada)'
      end

      it "should handle crossing the DST start boundary" do
        [
          "2011-03-14 12:00 PDT",
          "2011-03-14 00:00 PDT",
          "2011-03-13 03:00 PDT",
          "2011-03-13 01:00 PST",
          "2011-03-12 00:00 PST",
          "2011-03-11 00:00 PST",
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2011-03-14 00:30:00 -0700")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(4)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("Fri, 11 Mar 2011 00:00:00 PST -08:00"), 1],
            [Time.zone.parse("Sat, 12 Mar 2011 00:00:00 PST -08:00"), 1],
            [Time.zone.parse("Sun, 13 Mar 2011 00:00:00 PST -08:00"), 2],
            [Time.zone.parse("Mon, 14 Mar 2011 00:00:00 PDT -07:00"), 2]
          ]
      end

      it "should handle crossing the DST end boundary" do
        [
          "2010-11-08 01:00 PST",
          "2010-11-07 03:00 PST",
          "2010-11-07 02:00 PST",
          "2010-11-07 00:00 PDT",
          "2010-11-06 00:00 PDT",
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2010-11-08 00:00:00 -0800")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(3)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("Sat, 06 Nov 2010 00:00:00 PDT -07:00"), 1],
            [Time.zone.parse("Sun, 07 Nov 2010 00:00:00 PDT -07:00"), 3],
            [Time.zone.parse("Mon, 08 Nov 2010 00:00:00 PST -08:00"), 1]
          ]
      end

      it "should handle crossing both the DST start and end boundaries at the same time" do
        [
          # DST end boundary
          "2010-11-08 01:00 PST",
          "2010-11-07 02:01 PST",
          "2010-11-07 01:59 PDT",
          "2010-11-07 00:00 PDT",
          "2010-11-06 00:00 PDT",
          # DST start boundary
          "2011-03-14 00:00 PDT",
          "2011-03-13 03:00 PDT",
          "2011-03-13 01:59 PST",
          "2011-03-13 00:00 PST",
          "2011-03-12 00:00 PST",
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2011-03-18 00:00:00 -0800")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(135)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("2010-11-06 00:00 PDT"), 1],
            [Time.zone.parse("2010-11-07 00:00 PDT"), 3],
            [Time.zone.parse("2010-11-08 00:00 PST"), 1],
            [Time.zone.parse("2011-03-12 00:00 PST"), 1],
            [Time.zone.parse("2011-03-13 00:00 PST"), 3],
            [Time.zone.parse("2011-03-14 00:00 PDT"), 1]
          ]
      end

      it "should only return reports within the given window" do
        [
          "2009-11-12 12:00 PST",
          "2009-11-12 00:01 PST",
          "2009-11-11 23:59 PST",
          "2009-11-10 23:59 PST",
          "2009-11-10 23:49 PST",
          "2009-11-09 12:00 PST"
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2009-11-11 00:00 PST")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(2)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("2009-11-10 00:00 PST"), 2],
            [Time.zone.parse("2009-11-11 00:00 PST"), 1],
          ]
      end

      it "should not count inspect reports" do
        [
          "2009-11-12 12:00 PST",
          "2009-11-12 00:01 PST",
          "2009-11-11 23:59 PST",
          "2009-11-10 23:59 PST",
          "2009-11-10 23:49 PST",
          "2009-11-09 12:00 PST"
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end
        Report.generate(:time => Time.zone.parse("2009-11-10 12:00 PST"), :kind => "inspect")

        time = Time.zone.parse("2009-11-10 00:00 PST")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(1)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("2009-11-10 00:00 PST"), 2]
          ]
      end
    end

    describe "when the local timezone is one that does not use DST" do
      before :each do
        Time.zone = 'Tokyo'
      end

      it "should handle crossing the DST start boundary" do
        [
          # JST
          "2011-03-14 12:00 +09:00",
          "2011-03-14 00:00 +09:00",
          "2011-03-13 03:00 +09:00",
          "2011-03-13 01:00 +09:00",
          "2011-03-12 00:00 +09:00",
          "2011-03-11 00:00 +09:00",
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2011-03-14 00:30:00 +0900")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(4)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("Fri, 11 Mar 2011 00:00:00 +09:00"), 1],
            [Time.zone.parse("Sat, 12 Mar 2011 00:00:00 +09:00"), 1],
            [Time.zone.parse("Sun, 13 Mar 2011 00:00:00 +09:00"), 2],
            [Time.zone.parse("Mon, 14 Mar 2011 00:00:00 +09:00"), 2]
          ]
      end

      it "should handle crossing the DST end boundary" do
        [
          # JST
          "2010-11-08 01:00 +09:00",
          "2010-11-07 03:00 +09:00",
          "2010-11-07 02:00 +09:00",
          "2010-11-07 00:00 +09:00",
          "2010-11-06 00:00 +09:00",
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2010-11-08 00:00:00 +0900")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(3)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("Sat, 06 Nov 2010 00:00:00 +09:00"), 1],
            [Time.zone.parse("Sun, 07 Nov 2010 00:00:00 +09:00"), 3],
            [Time.zone.parse("Mon, 08 Nov 2010 00:00:00 +09:00"), 1]
          ]
      end

      it "should handle crossing both the DST start and end boundaries at the same time" do
        [
          # Non-existent DST end boundary in JST
          "2010-11-08 01:00 +09:00",
          "2010-11-07 02:01 +09:00",
          "2010-11-07 01:59 +09:00",
          "2010-11-07 00:00 +09:00",
          "2010-11-06 00:00 +09:00",
          # Non-existent DST start boundary in JST
          "2011-03-14 00:00 +09:00",
          "2011-03-13 03:00 +09:00",
          "2011-03-13 01:59 +09:00",
          "2011-03-13 00:00 +09:00",
          "2011-03-12 00:00 +09:00",
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2011-03-18 00:00:00 +0900")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(135)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("2010-11-06 00:00 +09:00"), 1],
            [Time.zone.parse("2010-11-07 00:00 +09:00"), 3],
            [Time.zone.parse("2010-11-08 00:00 +09:00"), 1],
            [Time.zone.parse("2011-03-12 00:00 +09:00"), 1],
            [Time.zone.parse("2011-03-13 00:00 +09:00"), 3],
            [Time.zone.parse("2011-03-14 00:00 +09:00"), 1]
          ]
      end

      it "should only return reports within the given window" do
        [
          # JST
          "2009-11-12 12:00 +09:00",
          "2009-11-12 00:01 +09:00",
          "2009-11-11 23:59 +09:00",
          "2009-11-10 23:59 +09:00",
          "2009-11-10 23:49 +09:00",
          "2009-11-09 12:00 +09:00"
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end

        time = Time.zone.parse("2009-11-11 00:00 JST")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(2)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("2009-11-10 00:00 +09:00"), 2],
            [Time.zone.parse("2009-11-11 00:00 +09:00"), 1],
          ]
      end

      it "should not count inspect reports" do
        [
          # JST
          "2009-11-12 12:00 +09:00",
          "2009-11-12 00:01 +09:00",
          "2009-11-11 23:59 +09:00",
          "2009-11-10 23:59 +09:00",
          "2009-11-10 23:49 +09:00",
          "2009-11-09 12:00 +09:00"
        ].each do |date_string|
          time = Time.zone.parse(date_string)
          Report.generate!(:time => time)
        end
        Report.generate(:time => Time.zone.parse("2009-11-10 12:00 +09:00"), :kind => "inspect")

        time = Time.zone.parse("2009-11-10 00:00 +09:00")
        ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)
        SETTINGS.stubs(:daily_run_history_length).returns(1)

        Status.within_daily_run_history.map{|s| [s.start, s.total]}.
          should == [
            [Time.zone.parse("2009-11-10 00:00 +09:00"), 2]
          ]
      end
    end
  end
end
