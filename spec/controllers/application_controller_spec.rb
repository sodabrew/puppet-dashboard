require 'spec_helper'

describe ApplicationController, :type => :controller do
  before do
    class ApplicationController
      def generic_action
        @time_zone = Time.zone
      end
    end

    Rails.application.routes.draw do |map|
      get 'application/generic_action'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  before :each do
    Time.zone = 'UTC'
  end

  it "should set the timezone to whatever is in SETTINGS.time_zone" do
    SETTINGS.stubs(:time_zone).returns('Pacific Time (US & Canada)')
    head :generic_action
    Time.zone.name.should == "Pacific Time (US & Canada)"
  end

  it "should raise if SETTINGS.time_zone is set to something invalid" do
    SETTINGS.stubs(:time_zone).returns('invalid')
    lambda { head :generic_action }.should raise_error StandardError, 'Invalid timezone "invalid"'
    Time.zone.name.should == "UTC"
  end
end
