require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module IncludeActionsSpec
  module Actions
    def foo; end
    def bar; end
    def faz; end
  end

  class ActionsController < ActionController::Base
    include_actions Actions
  end
  
  class OnlyFooController < ActionController::Base
    include_actions Actions, :only => :foo
  end
  
  class ExceptFooBarController < ActionController::Base
    include_actions Actions, :except => [:foo, :bar]
  end

  describe "Include actions use case" do
    it "ActionController should have actions from actions module" do
      ActionsController.action_methods.should == ['foo', 'bar', 'faz'].to_set
    end
    
    it "OnlyFooController should have only :foo from actions module" do
      OnlyFooController.action_methods.should == ['foo'].to_set
    end
    
    it "ExceptFooBarController should not have :foo, :bar from actions module" do
      ExceptFooBarController.action_methods.should == ['faz'].to_set
    end
  end
end
