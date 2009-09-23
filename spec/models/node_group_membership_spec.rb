require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroupMembership do
  it { should belong_to(:node) }
  it { should belong_to(:node_group) }
end
