require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/show.html.erb" do
  include NodeGroupsHelper
  before(:each) do
    assigns[:node_group] = @node_group = NodeGroup.generate
  end
end

