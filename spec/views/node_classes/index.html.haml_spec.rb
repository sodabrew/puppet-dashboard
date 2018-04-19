require 'spec_helper'

describe "/node_classes/index.html.haml", :type => :view do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      view.stubs(:action_name => 'index')
      @node_classes = [ create(:node_class), create(:node_class) ].paginate
      render
    end

    it "has node class items" do
      rendered.should have_tag('.node_class', :count => @node_classes.size)
      rendered.should have_tag("#node_class_#{@node_classes.last.id}")
    end

    it { rendered.should have_tag('form.search') }
  end
end
