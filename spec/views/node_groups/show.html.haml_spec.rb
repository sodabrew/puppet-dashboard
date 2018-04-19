require 'spec_helper'

describe "/node_groups/show.html.haml", :type => :view do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      assigns[:node_group] = @node_group = create(:node_group)
      render
    end

    it { rendered.should have_tag 'h2', :text => /Group:\n#{@node_group.name}/ }
  end
end
