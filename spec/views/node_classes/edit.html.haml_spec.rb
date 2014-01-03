require 'spec_helper'

describe "/node_classes/edit.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      @node_class = NodeClass.generate!
      render
    end

    it { rendered.should have_tag('form', :with => { :method => 'post', :action => node_class_path(@node_class.id) }) }
  end
end
