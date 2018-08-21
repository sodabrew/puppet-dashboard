require 'spec_helper'

describe "/nodes/new.html.haml", :type => :view do
  include NodesHelper

  describe "successful render" do
    before :each do
      assigns[:node] = @node = build(:node)
      render
    end

    it { rendered.should have_tag('form[method=post]', :with => { :action => nodes_path }) }
  end
end
