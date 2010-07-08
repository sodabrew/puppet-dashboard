require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_classes/index.html.haml" do
  include NodeClassesHelper

  before(:each) do
    assigns[:node_classes] = [ NodeClass.generate, NodeClass.generate ]
  end

  describe "the response"  do
    before { render }
    subject { response }

    it { should be_a_success }

    it "has node class items" do
      should have_tag('table.main tr.node_class', assigns[:node_classes].size)
      should have_tag("table.main tr#node_class_#{assigns[:node_classes].last.id}")
    end
  end

  it "renders the search form" do
    template.should_receive(:render).with('shared/search')
    render
  end

end
