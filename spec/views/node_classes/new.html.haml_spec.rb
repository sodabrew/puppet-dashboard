require 'spec_helper'

describe "/node_classes/new.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      assigns[:node_class] = @node_class = NodeClass.generate!
      render
    end

    it { rendered.should have_tag('form', :with => { :method => 'post', :action => node_class_path(@node_class) }) }
  end
end
