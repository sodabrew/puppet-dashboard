require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module PickTemplateSpec
  # example setup
  class TemplateOnlyController < ActionController::Base
    self.view_paths = [File.join(File.dirname(__FILE__), '../fixtures/views')]
  end

  class RespondToTypesController < TemplateOnlyController
    def an_action
      respond_to :atom, :xml, :html, :js
    end
  end

  class RespondToBlockController < TemplateOnlyController
    def an_action
      respond_to do |format|
        format.atom
        format.xml
        format.html
        format.js
      end
    end
  end

  class ResponseForTypesController < TemplateOnlyController
    response_for :an_action, :types => [:atom, :xml, :html, :js]
  end

  class ResponseForBlockController < TemplateOnlyController
    response_for :an_action do |format|
      format.atom
      format.xml
      format.html
      format.js
    end
  end

  class ResponseForMixOfBlockAndTypesController < TemplateOnlyController
    # response_for gives priority to most recent declarations, and
    # gives priority of blocks over types.
    response_for :an_action, :types => :js
    response_for :an_action, :types => :html
    response_for :an_action, :types => :xml do |format|
      format.atom
    end
  end

  class SuperclassController < TemplateOnlyController
    response_for :an_action, :types => :js
  end

  class InheritedController < SuperclassController
    response_for :an_action, :types => [:xml, :html] do |format|
      format.atom
    end
  end
  
  # specs
  describe "Standard behaviour of respond_to :atom, :xml, :html, :js", :shared => true do
    it "GET :an_action, should render an_action.atom" do
      get :an_action
      response.body.should == 'body of an_action.atom'
    end
    
    describe "GET :an_action, HTTP_ACCEPT =" do
      it "text/html, should render an_action.html" do
        request.env["HTTP_ACCEPT"] = 'text/html'
        get :an_action
        response.body.should == 'body of an_action.html'
      end

      it "application/xml, should render an_action.xml" do
        request.env["HTTP_ACCEPT"] = 'application/xml'
        get :an_action
        response.body.should == 'body of an_action.xml'
      end

      it "text/javascript, should render an_action.js" do
        request.env["HTTP_ACCEPT"] = 'text/javascript'
        get :an_action
        response.body.should == 'body of an_action.js'
      end

      it "application/atom+xml, should render an_action.atom" do
        request.env["HTTP_ACCEPT"] = 'application/atom+xml'
        get :an_action
        response.body.should == 'body of an_action.atom'
      end
    end
    
    describe "GET :an_action, :format =>" do
      it ":html, should render an_action.html" do
        get :an_action, :format => 'html'
        response.body.should == 'body of an_action.html'
      end

      it ":js, should render an_action.js" do
        get :an_action, :format => 'js'
        response.body.should == 'body of an_action.js'
      end

      it ":xml, should render an_action.xml" do
        get :an_action, :format => 'xml'
        response.body.should == 'body of an_action.xml'
      end

      it ":atom, should render an_action.atom" do
        get :an_action, :format => 'atom'
        response.body.should == 'body of an_action.atom'
      end
    end
  end

  describe "Picking template" do
    integrate_views

    describe TemplateOnlyController do
      describe "GET :an_action, HTTP_ACCEPT =" do
        it "text/html, should render an_action.html" do
          request.env["HTTP_ACCEPT"] = 'text/html'
          get :an_action
          response.body.should == 'body of an_action.html'
        end

        it "application/xml, should IGNORE and render an_action.html" do
          request.env["HTTP_ACCEPT"] = 'application/xml'
          get :an_action
          response.body.should == 'body of an_action.html'
        end
      end
    end

    describe "[:atom, :xml, :html, :js]" do
      describe RespondToTypesController do
        it_should_behave_like "Standard behaviour of respond_to :atom, :xml, :html, :js"
      end

      describe RespondToBlockController do
        it_should_behave_like "Standard behaviour of respond_to :atom, :xml, :html, :js"
      end

      describe ResponseForTypesController do
        it_should_behave_like "Standard behaviour of respond_to :atom, :xml, :html, :js"
      end

      describe ResponseForBlockController do
        it_should_behave_like "Standard behaviour of respond_to :atom, :xml, :html, :js"
      end

      describe ResponseForMixOfBlockAndTypesController do
        it_should_behave_like "Standard behaviour of respond_to :atom, :xml, :html, :js"
      end
  
      describe InheritedController do
        it_should_behave_like "Standard behaviour of respond_to :atom, :xml, :html, :js"
      end
    end
  end
end