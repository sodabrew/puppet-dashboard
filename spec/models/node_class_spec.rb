require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeClass do
  it { should validate_presence_of(:name) }

  ["", "with spaces", "invalid ch*r", "CAPS", "single:colon", "::beginswithcolon", "endswithcolons::"].each do |name|
    it { should_not allow_value(name).for(:name) }
  end

  ["a", "alpha", "alpha123", "namespaced::class", "more::n2ame::sp-ace", "hypen-name", "1numfirst" ].each do |name|
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

  describe "helper" do
    before :each do
      @classes = Array.new(3) {|idx| NodeClass.generate! :name => "class_#{idx}"}
    end

    describe "find_from_form_names" do
      it "should work with a single name" do
        classes = NodeClass.find_from_form_names("class_0")

        classes.size.should == 1
        classes.should include(@classes.first)
      end

      it "should work with multiple names" do
        classes = NodeClass.find_from_form_names("class_0", "class_2")

        classes.size.should == 2
        classes.should include(@classes.first, @classes.last)
      end
    end

    describe "find_from_form_ids" do
      it "should work with a single id" do
        classes = NodeClass.find_from_form_ids(@classes.first.id)

        classes.size.should == 1
        classes.should include(@classes.first)
      end

      it "should work with multiple ids" do
        classes = NodeClass.find_from_form_ids(@classes.first.id, @classes.last.id)

        classes.size.should == 2
        classes.should include(@classes.first, @classes.last)
      end

      it "should work with comma separated ids" do
        classes = NodeClass.find_from_form_ids("#{@classes.first.id},#{@classes.last.id}")

        classes.size.should == 2
        classes.should include(@classes.first, @classes.last)
      end
    end
  end
end
