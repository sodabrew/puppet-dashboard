require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeClass do
  it { should validate_presence_of(:name) }

  ["with spaces", "invalid ch*r"].each do |name|
    it { should_not allow_value(name).for(:name) }
  end

  ["alpha", "alpha123", "namespaced::class" ].each do |name|
    it { should allow_value(name).for(:name) }
  end

  describe "when destroying" do
    before :each do
      @node_class = NodeClass.generate!()
    end

    it "should disassociate member nodes from the class" do
      node = Node.generate!()
      node.node_classes << @node_class

      @node_class.destroy

      node.node_classes.reload.should be_empty
      node.node_class_memberships.reload.should be_empty
    end

    it "should disassociate node groups from the class" do
      node_group = NodeGroup.generate!()
      node_group.node_classes << @node_class

      @node_class.destroy

      node_group.node_classes.reload.should be_empty
      node_group.node_group_class_memberships.reload.should be_empty
    end
  end
end
