require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module Bug0001Spec
  class Thing < ActiveRecord::Base
  end
  
  class MyController < ActionController::Base
    def respond_to_with_cruft?(method)
      respond_to_without_cruft?(method)
    end
    alias_method_chain :respond_to?, :cruft
    
    resources_controller_for :things, :class => Thing
  end
  
  describe "Calling respond_to? when it has an old signature buried in there [#1]" do
    it "should work just fine" do
      c = MyController.new
      c.respond_to?(:foo).should == false
    end
  end
end