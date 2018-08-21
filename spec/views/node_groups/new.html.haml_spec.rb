require 'spec_helper'

describe "/node_groups/new.html.haml", :type => :view do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      assigns[:node_group] = @node_group = build(:node_group)
      render
    end

    it { rendered.should have_tag('form[method=post]', :with => { :action => node_groups_path }) }
  end
end
