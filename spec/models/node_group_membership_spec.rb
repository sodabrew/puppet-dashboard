require 'spec_helper'

describe NodeGroupMembership, :type => :model do
  it { should belong_to(:node) }
  it { should belong_to(:node_group) }

  it "should only allow a single association between the same node and group" do
    node = create(:node)
    node_group = create(:node_group)
    membership = NodeGroupMembership.create(:node => node, :node_group => node_group)

    membership.should be_valid

    duplicate = NodeGroupMembership.create(:node => node, :node_group => node_group)
    duplicate.should_not be_valid
  end
end
