require 'spec_helper'

describe "/node_groups/index.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      view.stubs(:action_name => 'index')
      assigns[:node_groups] = @node_groups = [ NodeGroup.generate!, NodeGroup.generate! ].paginate
      render
    end

    it { rendered.should have_tag('.node_group', :count => @node_groups.size) }
    it { rendered.should have_tag("#node_group_#{@node_groups.last.id}") }
    it { rendered.should have_tag('form.search') }
  end
end
