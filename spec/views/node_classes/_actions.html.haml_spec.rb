require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_classes/_actions.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before { render }

    specify { response.should be_success }
    it { should have_tag('a[href=?]', new_node_class_path) }
  end
end
