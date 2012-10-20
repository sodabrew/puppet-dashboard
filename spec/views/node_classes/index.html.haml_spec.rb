require 'spec_helper'

describe "/node_classes/index.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      view.stubs(:action_name => 'index')
      assigns[:node_classes] = [ NodeClass.generate!, NodeClass.generate! ].paginate
      render
    end

    specify { rendered.should be_a_success }

    it "has node class items" do
      should have_tag('.node_class', assigns[:node_classes].size)
      should have_tag("#node_class_#{assigns[:node_classes].last.id}")
    end

    it { should have_tag('form.search') }
  end
end
