require 'spec_helper'

describe "/node_groups/_actions.html.haml" do
  include NodesHelper

  describe "successful render" do
    before { render }

    it { rendered.should have_tag('a', :with => { :href => new_node_group_path }) }
  end
end
