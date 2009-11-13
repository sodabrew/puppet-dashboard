require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroup do
  before { @node_group = NodeGroup.spawn }
  it { should have_many(:node_classes).through(:node_group_class_memberships) }
  it { should have_many(:nodes).through(:node_group_memberships) }
end
