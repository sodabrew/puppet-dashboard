require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class InheritedFromApplicationController < ApplicationController
  def generic_action
    @time_zone = Time.zone
  end
end

describe InheritedFromApplicationController do
  before :each do
    Time.zone = 'UTC'
  end

  it "should set the timezone to whatever is in SETTINGS.time_zone" do
    SETTINGS.stubs(:time_zone).returns('Pacific Time (US & Canada)')
    get :generic_action
    Time.zone.name.should == "Pacific Time (US & Canada)"
  end

  it "should raise if SETTINGS.time_zone is set to something invalid" do
    SETTINGS.stubs(:time_zone).returns('invalid')
    lambda { get :generic_action }.should raise_error
    Time.zone.name.should == "UTC"
  end
end
