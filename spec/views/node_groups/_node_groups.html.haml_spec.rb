require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/_node_groups.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before do
      @node_groups = assigns[:node_groups] = [NodeGroup.generate!]
      render :locals => {:node_groups => @node_groups}
    end

    specify { response.should be_a_success }
    it { should have_tag('.node_group', @node_groups.size) }
    it { should have_tag("#node_group_#{@node_groups.first.id}") }
  end
end
