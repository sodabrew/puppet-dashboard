require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module DefaultRailsBehaviourSpec
  class TheController < ActionController::Base
    def two_respond_tos
      respond_to {|f| f.html { first }}
      respond_to {|f| f.html { second }}
      render :text => ""
    end
  
    def two_responses
      respond_to do |f|
        f.html { first }
        f.html { second }
      end
      render :text => ""
    end
  end

  describe TheController do
    describe "GET :two_respond_tos" do
      after { get :two_respond_tos }
    
      it "should recieve first and second in order" do
        @controller.should_receive(:first).once.ordered
        @controller.should_receive(:second).once.ordered
      end
    end
  
    describe "GET :two_responses" do
      after { get :two_responses }
    
      it "should only receive first and NOT second" do
        @controller.should_receive(:first).once
        @controller.should_not_receive(:second)
      end
    end
  end
end