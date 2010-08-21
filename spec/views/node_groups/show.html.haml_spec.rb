require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/show.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before do
      assigns[:node_group] = @node_group = NodeGroup.generate!
      render
    end

    specify { response.should be_success }
    it { should have_tag('h2', @node_group.name) }
  end
end
