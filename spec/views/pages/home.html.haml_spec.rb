require 'spec_helper'

describe '/pages/home.html.haml' do
  describe "successful render" do
    before :each do
      assigns[:all_nodes] = @all_nodes = [Node.generate!]
      assigns[:unreported_nodes] = []
      assigns[:unresponsive_nodes] = []
      assigns[:failed_nodes] = []
      assigns[:pending_nodes] = []
      assigns[:changed_nodes] = []
      assigns[:unchanged_nodes] = []
    end 

    render
  end

  it "should have a correct delayed_job_failures link" do
    rendered.should have_tag('a', :href => '/delayed_job_failures', :text => 'Background Tasks')
  end

  it "should have a correct radiator link" do
    rendered.should have_tag('a', :href => '/radiator', :text => 'Radiator View')
  end
end
