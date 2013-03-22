require 'spec_helper'

describe "/nodes/new.html.haml" do
  include NodesHelper

  describe "successful render" do
    before :each do
      assigns[:node] = @node = Node.spawn
      render
    end

    it { rendered.should have_tag('form[method=post]', :with => { :action => nodes_path }) }
  end
end
