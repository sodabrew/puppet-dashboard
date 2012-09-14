require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

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

    specify do
      render
      response.should be_success
    end

    it "should have a correct delayed_job_failures link" do
      render
      should have_tag('a[href="/delayed_job_failures"]', 'Background Tasks')
    end
  end
end
