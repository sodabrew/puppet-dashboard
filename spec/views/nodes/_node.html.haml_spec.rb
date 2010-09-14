require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/nodes/_node.html.haml" do
  include NodesHelper

  describe "successful render" do
    before :each do
      @node = Node.generate!
      render :locals => {:node => @node}
    end

    specify { response.should be_a_success }
    it { should have_tag(".node#node_#{@node.id}") }
    it { should have_tag('h3', @node.name) }
  end
end
