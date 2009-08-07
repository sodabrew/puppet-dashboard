require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

# this spec shows how to stack responses - the important thing to note is that
# once a format block is executed, that will stop all subsequent blocks of that
# type being called.
module StackingResponsesSpec
  class TheController < ActionController::Base
    response_for :foo do |format|
      format.html do
        render :text => "default"
      end
    end
    
    response_for :foo do |format|
      in_first
      if params[:first]
        format.html do
          in_first_html
          redirect_to 'http://first'
        end
      end
    end
    
    response_for :foo do |format|
      in_second
      if params[:second]
        format.html do
          in_second_html
          redirect_to 'http://second'
        end
      end
    end
        
  protected
    def in_first; end
    def in_first_html; end
    def in_second; end
    def in_second_html; end
  end
  
  describe TheController, "with responses conditionally executed" do
    describe "GET :foo (no conditions)" do
      it "should execute second, then first, response" do
        @controller.should_receive(:in_second).once.ordered
        @controller.should_receive(:in_first).once.ordered
        get :foo
      end
      
      it "should NOT execute the html response in first" do
        @controller.should_not_receive(:in_first_html)
        get :foo
      end
      
      it "should NOT execute the html response in second" do
        @controller.should_not_receive(:in_second_html)
        get :foo
      end
      
      it "should render the default response" do
        get :foo
        response.body.should == "default"
      end
    end
    
    describe "GET :foo, :second => true" do
      it "should execute second, then first, then html second, response" do
        @controller.should_receive(:in_second).once.ordered
        @controller.should_receive(:in_first).once.ordered
        @controller.should_receive(:in_second_html).once.ordered
        get :foo, :second => true
      end

      it "should redirect from second response" do
        get :foo, :second => true
        response.should redirect_to('http://second')
      end

      it "should NOT execute first html response" do
        @controller.should_not_receive(:in_first_html)
        get :foo, :second => true
      end
    end
    
    describe "GET :foo, :first => true" do
      it "should execute second, then first, then first html response" do
        @controller.should_receive(:in_second).once.ordered
        @controller.should_receive(:in_first).once.ordered
        @controller.should_receive(:in_first_html).once.ordered
        get :foo, :first => true
      end

      it "should redirect from first response" do
        get :foo, :first => true
        response.should redirect_to('http://first')
      end
      
      it "should NOT execute second html response" do
        @controller.should_not_receive(:in_second_html)
        get :foo, :first => true
      end
    end
    
    describe "GET :foo, :first => true, :second => true (can't execute two html blocks)" do
      it "should execute second, then first, then second html response" do
        @controller.should_receive(:in_second).once.ordered
        @controller.should_receive(:in_first).once.ordered
        @controller.should_receive(:in_second_html).once.ordered
        get :foo, :first => true, :second => true
      end

      it "should redirect from second response" do
        get :foo, :first => true, :second => true
        response.should redirect_to('http://second')
      end
      
      it "should NOT execute first html response" do
        @controller.should_not_receive(:in_first_html)
        get :foo, :first => true, :second => true
      end
    end
  end
end