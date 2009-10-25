require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroup do
  it { should have_many(:node_classes).through(:node_group_class_memberships) }
end
