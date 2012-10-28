require 'spec_helper'

describe "/nodes/show.html.haml" do
  include NodesHelper

  describe "successful render" do
    before(:each) do
      @report = Report.generate!
      assigns[:node] = @node = @report.node
      render :template => "/nodes/show"
    end

    it { rendered.should have_tag('h2', :text => /#{@node.name}/) }
  end
end
