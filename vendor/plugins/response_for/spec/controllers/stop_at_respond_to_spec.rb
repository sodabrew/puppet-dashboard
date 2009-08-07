require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module StopAtRespondToSpec
  class TheController < ActionController::Base
    self.view_paths = [File.join(File.dirname(__FILE__), '../fixtures/views')]
    
    def index
      respond_to do |format|
        format.html do
          @html = true
        end
        format.atom do
          @atom = true
        end
      end
    end
  end

  describe "Standard respond_to behaviour", :shared => true do
    it "should render the respond_to html response" do
      request.env["HTTP_ACCEPT"] = 'text/html'
      get :index
      assigns['html'].should == true
      response.body.should =~ /body of index\.html\.erb/
    end
    
    it "should render the respond_to atom response" do
      request.env["HTTP_ACCEPT"] = 'application/atom+xml'
      get :index
      assigns['atom'].should == true
      response.body.should =~ /body of index\.atom\.builder/
    end
  end
  
  describe TheController do
    integrate_views
    
    it_should_behave_like "Standard respond_to behaviour"
    
    describe "with a redundant response_for" do
      before do
        # this should be ignored, because index has a respond_to
        TheController.response_for :index do |format|
          format.html
          format.js
          format.xml
        end
      end
      
      it_should_behave_like "Standard respond_to behaviour"
    end      
  end
end