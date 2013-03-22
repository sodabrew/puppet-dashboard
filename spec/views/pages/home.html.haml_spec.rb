require 'spec_helper'

describe '/pages/home' do
  before :each do
    @all_nodes          = [Node.generate!]
    @unreported_nodes   = []
    @unresponsive_nodes = []
    @failed_nodes       = []
    @pending_nodes      = []
    @changed_nodes      = []
    @unchanged_nodes    = []

    render
  end

  it "should have a correct delayed_job_failures link" do
    rendered.should have_tag('a', :href => '/delayed_job_failures', :text => 'Background Tasks')
  end

  it "should have a correct radiator link" do
    rendered.should have_tag('a', :href => '/radiator', :text => 'Radiator View')
  end
end
