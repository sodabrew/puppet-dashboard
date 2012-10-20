require 'spec_helper'

describe "/node_groups/_actions.html.haml" do
  include NodesHelper

  describe "successful render" do
    before { render }

    specify { rendered.should be_success }
    it { should have_tag('a[href=?]', new_node_group_path) }
  end
end
