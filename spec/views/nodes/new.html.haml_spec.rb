require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/nodes/new.html.haml" do
  include NodesHelper

  describe "successful render" do
    before :each do
      assigns[:node] = @node = Node.spawn
      render
    end

    specify { response.should be_success }
    it { should have_tag('form[method=post][action=?]', nodes_path) }
  end
end
