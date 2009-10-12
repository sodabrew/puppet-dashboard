require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/index.html.erb" do
  include NodeGroupsHelper
  
  before(:each) do
    assigns[:node_groups] = [ NodeGroup.generate, NodeGroup.generate ]
  end

  it "renders a list of node_groups" do
    render
  end
end

