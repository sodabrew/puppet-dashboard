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

  describe "when including groups" do
    before do
      @node_group_a = NodeGroup.generate! :name => "A"
      @node_group_b = NodeGroup.generate! :name => "B"
    end

    describe "by id" do
      it "should not allow a group to include itself" do
        @node_group_a.node_group_ids = @node_group_a.id
        @node_group_a.save

        @node_group_a.should_not be_valid
        @node_group_a.errors.full_messages.should include("Validation failed: Creating a dependency from group 'A' to itself creates a cycle")
        @node_group_a.node_groups.should be_empty
      end

      it "should not allow a cycle to be formed" do
        @node_group_b.node_groups << @node_group_a
        @node_group_a.node_group_ids = @node_group_b.id
        @node_group_a.save

        @node_group_a.should_not be_valid
        @node_group_a.errors.full_messages.should include("Validation failed: Creating a dependency from group 'A' to group 'B' creates a cycle")
        @node_group_a.node_groups.should be_empty
      end

      it "should allow a group to be included twice through inheritance" do
        @node_group_c = NodeGroup.generate!
        @node_group_d = NodeGroup.generate!
        @node_group_a.node_groups << @node_group_c
        @node_group_b.node_groups << @node_group_c
        @node_group_d.node_group_ids = [@node_group_a.id, @node_group_b.id]

        @node_group_d.should be_valid
        @node_group_d.errors.should be_empty
        @node_group_d.node_groups.should include(@node_group_a,@node_group_b)
      end
    end

    describe "by name" do
      it "should not allow a group to include itself" do
        @node_group_a.node_group_names = @node_group_a.name
        @node_group_a.save

        @node_group_a.should_not be_valid
        @node_group_a.errors.full_messages.should include("Validation failed: Creating a dependency from group 'A' to itself creates a cycle")
        @node_group_a.node_groups.should be_empty
      end

      it "should not allow a cycle to be formed" do
        @node_group_b.node_groups << @node_group_a
        @node_group_a.node_group_names = @node_group_b.name
        @node_group_a.save

        @node_group_a.should_not be_valid
        @node_group_a.errors.full_messages.should include("Validation failed: Creating a dependency from group 'A' to group 'B' creates a cycle")
        @node_group_a.node_groups.should be_empty
      end

      it "should allow a group to be included twice through inheritance" do
        @node_group_c = NodeGroup.generate!
        @node_group_d = NodeGroup.generate!
        @node_group_a.node_groups << @node_group_c
        @node_group_b.node_groups << @node_group_c
        @node_group_d.node_group_names = [@node_group_a.name, @node_group_b.name]

        @node_group_d.should be_valid
        @node_group_d.errors.should be_empty
        @node_group_d.node_groups.should include(@node_group_a,@node_group_b)
      end
    end
  end

  describe "when including classes" do
    before :each do
      NodeGroup.delete_all
      NodeClass.delete_all

      @node_group   = NodeGroup.generate!
      @node_class_a = NodeClass.generate! :name => "class_a"
      @node_class_b = NodeClass.generate! :name => "class_b"
    end

    describe "by id" do
      describe "with a single id" do
        it "should set the class" do
          @node_group.node_class_ids = @node_class_a.id

          @node_group.should be_valid
          @node_group.errors.should be_empty
          @node_group.node_classes.size.should == 1
          @node_group.node_classes.should include(@node_class_a)
        end
      end

      describe "with multiple ids" do
        it "should set the classes" do
          @node_group.node_class_ids = [@node_class_a.id, @node_class_b.id]

          @node_group.should be_valid
          @node_group.errors.should be_empty
          @node_group.node_classes.size.should == 2
          @node_group.node_classes.should include(@node_class_a, @node_class_b)
        end
      end
    end

    describe "by name" do
      describe "with a single name" do
        it "should set the class" do
          @node_group.node_class_names = @node_class_a.name

          @node_group.should be_valid
          @node_group.errors.should be_empty
          @node_group.node_classes.size.should == 1
          @node_group.node_classes.should include(@node_class_a)
        end
      end

      describe "with multiple names" do
        it "should set the classes" do
          @node_group.node_class_names = [@node_class_a.name, @node_class_b.name]

          @node_group.should be_valid
          @node_group.errors.should be_empty
          @node_group.node_classes.size.should == 2
          @node_group.node_classes.should include(@node_class_a, @node_class_b)
        end
      end
    end

    describe "by name, and id" do
      it "should add all specified classes" do
        @node_group.node_class_names = @node_class_a.name
        @node_group.node_class_ids   = @node_class_b.id

        @node_group.should be_valid
        @node_group.errors.should be_empty
        @node_group.node_classes.size.should == 2
        @node_group.node_classes.should include(@node_class_a, @node_class_b)
      end
    end
  end

  describe "helper" do
    before :all do
      NodeGroup.delete_all

      @groups = Array.new(3) {|idx| NodeGroup.generate! :name => "Group #{idx}"}
    end

    describe "find_from_form_names" do
      it "should work with a single name" do
        group = NodeGroup.find_from_form_names("Group 0")

        group.should include(@groups.first)
      end

      it "should work with multiple names" do
        group = NodeGroup.find_from_form_names("Group 0", "Group 2")

        group.size.should == 2
        group.should include(@groups.first, @groups.last)
      end
    end

    describe "find_from_form_ids" do
      it "should work with a single id" do
        group = NodeGroup.find_from_form_ids(@groups.first.id)

        group.size.should == 1
        group.should include(@groups.first)
      end

      it "should work with multiple ids" do
        group = NodeGroup.find_from_form_ids(@groups.first.id, @groups.last.id)

        group.size.should == 2
        group.should include(@groups.first, @groups.last)
      end

      it "should work with comma separated ids" do
        group = NodeGroup.find_from_form_ids("#{@groups.first.id},#{@groups.last.id}")

        group.size.should == 2
        group.should include(@groups.first, @groups.last)
      end
    end
  end
end
