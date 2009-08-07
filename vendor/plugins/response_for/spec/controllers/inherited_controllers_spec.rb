require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module InheritedControllerSpec
  # example setup
  class SuperController < ActionController::Base
    response_for :a_response do |format|
      format.html { super_inside_a_response }
    end
    
    def an_action
      inside_an_action
    end
    
    def performing_action
      respond_to do |format|
        format.html { redirect_to 'http://redirected.from.an_action_which_performs' }
      end
    end
    
  protected
    def super_inside_a_response; end
    def inside_an_action; end
  end
  
  class SubController < SuperController
    response_for :a_response do |format|
      format.html { sub_inside_a_response }
    end
    
    response_for :an_action do |format|
      format.html do
        redirect_to 'http://redirected.from.response_for'
      end
    end
  
    response_for :performing_action do |format|
      never_reached_because_action_performs
    end
    
  protected
    def sub_inside_a_response; end
  end
  
  # specs
  describe "action_responses", :type => :spec do
    it "SuperController.action_responses should not == SubController.action_responses" do
      SuperController.action_responses.should_not == SubController.action_responses
    end
    
    it "SuperController should have one action_response for 'a_response'" do
      SuperController.action_responses.keys.should == ['a_response']
      SuperController.action_responses['a_response'].size.should == 1
    end
    
    it "SubController should have two action_responses for 'a_response', and one each for 'an_action', and 'performing_action'" do
      SubController.action_responses.keys.sort.should == ['a_response', 'an_action', 'performing_action']
      SubController.action_responses['a_response'].size.should == 2
      SubController.action_responses['an_action'].size.should == 1
      SubController.action_responses['performing_action'].size.should == 1
    end
  end
  
  describe SuperController do
    describe "GET :an_action" do
      it "should execute action" do
        spec = lambda do
          @controller.should_receive :inside_an_action
          get :an_action
        end
        Rails.version >= '2.3' ? pending("rspec/rails2.3 integrate_views working") { spec.call } : spec.call
      end
    
      it "should render :an_action" do
        spec = lambda do
          get :an_action
          # different rails/rspec behaviour catered for
          begin
            response.should render_template('an_action')
          rescue
            response.should render_template('inherited_spec/super/an_action')
          end
        end
        Rails.version >= '2.3' ? pending("rspec/rails2.3 integrate_views working") { spec.call } : spec.call
      end
    end
    
    describe "GET :a_response" do
      it "should execute inside the super response block" do
        spec = lambda do
          @controller.should_receive :super_inside_a_response
          get :a_response
        end
        Rails.version >= '2.3' ? pending("rspec/rails2.3 integrate_views working") { spec.call } : spec.call
      end
      
      it "should NOT execute inside the sub response block" do
        spec = lambda do
          @controller.should_not_receive :sub_inside_a_response
          get :a_response
        end
        Rails.version >= '2.3' ? pending("rspec/rails2.3 integrate_views working") { spec.call } : spec.call
      end
    end
    
    describe "GET :performing_action" do
      it "should redirect" do
        get :performing_action
        response.should redirect_to('http://redirected.from.an_action_which_performs')
      end
    end
  end

  describe SubController do
    describe "GET :an_action (decorated with redirecting response_for)" do
      it "should execute action" do
        @controller.should_receive :inside_an_action
        get :an_action
      end
    
      it "should redirect" do
        get :an_action
        response.should redirect_to('http://redirected.from.response_for')
      end
    end
    
    describe "GET :a_response (decorated with a new response)" do
      it "should NOT execute the super response" do
        spec = lambda do
          @controller.should_not_receive :super_inside_a_response
          get :a_response
        end
        Rails.version >= '2.3' ? pending("rspec/rails2.3 integrate_views working") { spec.call } : spec.call
      end

      it "should execute the sub response" do
        spec = lambda do
          @controller.should_receive :sub_inside_a_response
          get :a_response
        end
        Rails.version >= '2.3' ? pending("rspec/rails2.3 integrate_views working") { spec.call } : spec.call
      end
    end
    
    describe "GET :performing_action" do
      it "should NOT execute the sub response" do
        @controller.should_not_receive :never_reached_because_action_performs
        get :performing_action
      end
      
      it "should redirect as per the super def" do
        get :performing_action
        response.should redirect_to('http://redirected.from.an_action_which_performs')
      end
    end
  end
end