require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_classes/show.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      assigns[:node_class] = @node_class = NodeClass.generate!
      render
    end

    specify { response.should be_a_success }
    it { should have_tag('h2', "Class:\n#{@node_class.name}") }
  end
end
