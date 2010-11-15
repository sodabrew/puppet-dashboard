require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SETTINGS" do
  it "should allow you to set the datetime_format" do
    Time.zone = "UTC"
    SETTINGS.stubs(:datetime_format).returns('%d-%m-%Y')
    Time.utc("2010", "11", "12", 12, 15, 00).to_s.should == '12-11-2010'
  end

  it "should allow you to set the date_format" do
    Time.zone = "UTC"
    SETTINGS.stubs(:date_format).returns('%A %B %d, %Y')
    Time.utc("2010", "11", "12", 12, 15, 00).to_s(:date).should == 'Friday November 12, 2010'
  end
end

