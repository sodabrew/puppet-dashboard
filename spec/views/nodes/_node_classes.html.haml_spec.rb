require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/nodes/_node_classes.html.haml" do
  include NodesHelper

  describe "successful render" do
    before :each do
      assigns[:node] = @node = Node.generate!
      render :locals => {:node => @node}
    end

    specify { response.should be_success }
  end
end
