require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/index.html.haml" do
  include NodeGroupsHelper

  before(:each) do
    assigns[:node_groups] = [ NodeGroup.generate, NodeGroup.generate ]
  end

  describe "the response"  do
    before { render }
    subject { response }

    it { should be_a_success }

    it "has node class items" do
      should have_tag('table.main tr.node_group', assigns[:node_groups].size)
      should have_tag("table.main tr#node_group_#{assigns[:node_groups].last.id}")
    end
  end

  it "renders the search form" do
    template.should_receive(:render).with('shared/search')
    render
  end

end
