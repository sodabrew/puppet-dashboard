require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/edit.html.erb" do
  include NodeGroupsHelper
  
  before(:each) do
    assigns[:node_group] = @node_group = NodeGroup.generate
  end

  it "renders the edit node_group form" do
    render
    
    response.should have_tag("form[action=#{node_group_path(@node_group)}][method=post]") do
    end
  end
end


