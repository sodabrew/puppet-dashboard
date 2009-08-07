require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module NoResponseIfPerformedSpec
  # example setup
  class TheController < ActionController::Base
    before_filter :do_redirect
    
    response_for :an_action do |format|
      format.html { render :text => "in response for" }
    end
    
  protected
    def do_redirect
      redirect_to 'http://redirected.from.before_filter'
    end
  end
  
  describe TheController do
    describe "(when before_filter redirects)" do
      it "GET :an_action should redirect to 'http://redirected.from.before_filter'" do
        get :an_action
        response.should redirect_to('http://redirected.from.before_filter')
      end
    end
    
    describe "(when before_filter doesn't redirect)" do
      before do
        @controller.stub!(:do_redirect)
      end
      
      it "GET :an_action should execute inside response for" do
        get :an_action
        response.body.should == 'in response for'
      end
    end
  end
end