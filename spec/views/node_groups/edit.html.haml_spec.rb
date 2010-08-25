require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/edit.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before do
      assigns[:node_group] = @node_group = NodeGroup.generate!
      render
    end

    specify { response.should be_a_success }
    it { should have_tag('form[method=post][action=?]', node_group_path(@node_group)) }
  end
end
