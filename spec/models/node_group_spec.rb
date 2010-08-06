require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroup do
  describe "associations" do
    before { @node_group = NodeGroup.spawn }
    it { should have_many(:node_classes).through(:node_group_class_memberships) }
    it { should have_many(:nodes).through(:node_group_memberships) }
  end

  describe "when destroying" do
    before :each do
      @group = NodeGroup.generate!()
    end

    it "should disassociate nodes" do
      node = Node.generate!()
      node.node_groups << @group

      @group.destroy

      node.node_groups.reload.should be_empty
      node.node_group_memberships.reload.should be_empty
    end

    it "should disassociate node_classes" do
      node_class = NodeClass.generate!()
      @group.node_classes << node_class

      @group.destroy

      node_class.node_groups.reload.should be_empty
      node_class.node_group_class_memberships.reload.should be_empty
    end

    it "should disassociate node_groups" do
      group_last = NodeGroup.generate!()
      group_first = NodeGroup.generate!()

      group_first.node_groups << @group
      @group.node_groups << group_last

      @group.destroy

      group_first.reload.node_groups.should be_empty
      group_first.node_group_edges_out.should be_empty
      NodeGroupEdge.all.should be_empty
    end
  end
end
