require 'spec_helper'

describe "/node_groups/show.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      assigns[:node_group] = @node_group = NodeGroup.generate!
      render
    end

    specify { rendered.should be_success }
    it { should have_tag('h2', "Group:\n#{@node_group.name}") }
  end
end
