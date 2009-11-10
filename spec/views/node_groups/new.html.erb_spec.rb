require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/new.html.haml" do
  include NodeGroupsHelper
  
  before(:each) do
    assigns[:node_group] = @node_group = NodeGroup.spawn
  end

  it "renders new node_group form" do
    render
    
    response.should have_tag("form[action=?][method=post]", node_groups_path) do
    end
  end
end


