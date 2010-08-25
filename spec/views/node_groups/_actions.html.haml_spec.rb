require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/_actions.html.haml" do
  include NodesHelper

  describe "successful render" do
    before { render }

    specify { response.should be_success }
    it { should have_tag('a[href=?]', new_node_group_path) }
  end
end
