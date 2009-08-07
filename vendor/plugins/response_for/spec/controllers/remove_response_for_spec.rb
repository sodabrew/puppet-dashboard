require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module RemoveResponseForSpec
  class TheController < ActionController::Base
    response_for :foo, :bar, :types => :html
    response_for :foo, :types => :js
  end
  
  describe TheController do
    it "should have action_responses for :foo and :bar" do
      TheController.action_responses.keys.sort.should == ['bar', 'foo']
    end
    
    describe ".remove_response_for :bar" do
      before do
        TheController.remove_response_for :bar
      end
      
      it "should hanve action_responses for :foo" do
        TheController.action_responses.keys.should == ['foo']
      end
    end
    
    describe ".remove_response_for" do
      before do
        TheController.remove_response_for
      end
      
      it "should have empty action_responses" do
        TheController.action_responses.should be_empty
      end
    end
  end
end