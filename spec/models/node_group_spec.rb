require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroup do
  before { @node_group = NodeGroup.spawn }
  it { should have_many(:node_classes).through(:node_group_class_memberships) }
  it { should have_many(:nodes).through(:node_group_memberships) }

  describe "when including groups" do
    before do
      @node_group_a = NodeGroup.generate! :name => "A"
      @node_group_b = NodeGroup.generate! :name => "B"
    end

    it "should not allow a group to include itself" do
      @node_group_a.node_group_names = "A"
      @node_group_a.save

      @node_group_a.should_not be_valid
      @node_group_a.errors.full_messages.should include("Validation failed: Creating an edge from A to A creates a cycle")
      @node_group_a.node_groups.should be_empty
    end

    it "should not allow a cycle to be formed" do
      @node_group_b.node_groups << @node_group_a
      @node_group_a.node_group_names = "B"
      @node_group_a.save

      @node_group_a.should_not be_valid
      @node_group_a.errors.full_messages.should include("Validation failed: Creating an edge from A to B creates a cycle")
      @node_group_a.node_groups.should be_empty
    end

    it "should allow a group to be included twice" do
        @node_group_c = NodeGroup.generate!
        @node_group_d = NodeGroup.generate!
        @node_group_a.node_groups << @node_group_c
        @node_group_b.node_groups << @node_group_c
        @node_group_d.node_group_names = ["A","B"]

        @node_group_d.should be_valid
        @node_group_d.errors.should be_empty
        @node_group_d.node_groups.should include(@node_group_a,@node_group_b)
      end
  end
end
