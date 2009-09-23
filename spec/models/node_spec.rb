require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Node do
  describe 'attributes' do
    before :each do
      Node.generate!
      @node = Node.new
    end

    it { should have_many(:node_class_memberships) }
    it { should have_many(:node_classes).through(:node_class_memberships) }
    it { should have_many(:node_group_memberships) }
    it { should have_many(:node_groups).through(:node_group_memberships) }
    
    it { should have_db_column(:name).of_type(:string) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it 'should allow setting and retrieving parameter values' do
      @node.parameters = { :foo => 'bar' }
      @node.parameters[:foo].should == 'bar'
    end
    
    it 'should preserve parameters as a hash across saving' do
      @node = Node.generate!(:parameters => { :foo => 'bar'})
      Node.find(@node.id).parameters[:foo].should == 'bar'
    end
  end

  describe '#available_node_classes' do
    before do
      @node = Node.new
      @node_classes = Array.new(3){ NodeClass.generate! }
    end

    it "should include all available classes" do
      @node.available_node_classes.should == @node_classes
    end

    describe 'when the node has classes' do
      before { @node.node_classes << @node_classes.first }

      it "should not include the node's classes" do
        @node.available_node_classes.should_not include(@node_classes.first)
      end

    end
  end

  describe '#available_node_groups' do
    before do
      @node = Node.new
      @node_groups = Array.new(3){ NodeGroup.generate! }
    end

    it "should include all available groups" do
      @node.available_node_groups.should == @node_groups
    end

    describe 'when the node has groups' do
      before { @node.node_groups << @node_groups.first }

      it "should not include the node's groups" do
        @node.available_node_groups.should_not include(@node_groups.first)
      end

    end
  end

  it 'should be able to compute a configuration' do
    Node.new.should respond_to(:configuration)
  end
  
  describe 'when computing a configuration' do
    before :each do
      @node = Node.generate!
    end
    
    it 'should work without arguments' do
      lambda { @node.configuration }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @node.configuration(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should return a set of classes and parameters' do
      @node.configuration.keys.sort.should == ['classes', 'parameters']
    end
    
    it "should return the names of the node's classes in the returned class list" do
      @node.node_classes = @classes = Array.new(3) { NodeClass.generate! }
      @node.configuration['classes'].sort.should == @classes.collect(&:name).sort
    end
    
    it "should return the node's parameters in the returned parameters list" do
      @node.parameters = {'a' => 'b', 'c' => 'd'}
      @node.configuration['parameters'].should == { 'a' => 'b', 'c' => 'd' }  
    end
  end
end
