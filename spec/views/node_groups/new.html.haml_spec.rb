require 'spec_helper'

describe "/node_groups/new.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      assigns[:node_group] = @node_group = NodeGroup.spawn
      render
    end

    specify { rendered.should be_a_success }
    it { should have_tag('form[method=post][action=?]', node_groups_path) }
  end
end
