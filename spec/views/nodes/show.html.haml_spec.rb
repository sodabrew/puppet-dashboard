require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/nodes/show.html.haml" do
  include NodesHelper

  describe "successful render" do
    before(:each) do
      @report = Report.generate!
      assigns[:node] = @node = @report.node
      render
    end

    specify { response.should be_success }
    it { should have_tag('h2', /#{@node.name}/) }
  end
end
