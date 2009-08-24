require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Node do
  describe 'attributes' do
    before :each do
      @node = Node.new
    end
    
    it 'should have a name' do
      @node.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @node.name = 'test name'
      @node.name.should == 'test name'
    end

    it 'should have a description' do
      @node.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @node.description = 'test description'
      @node.description.should == 'test description'
    end
    
    it 'should have a set of parameters' do
      @node.should respond_to(:parameters)
    end
    
    it 'should allow setting and retrieving parameter values' do
      @node.parameters = { :foo => 'bar' }
      @node.parameters[:foo].should == 'bar'
    end
    
    it 'should preserve parameters as a hash across saving' do
      @node = Node.generate!(:parameters => { :foo => 'bar'})
      Node.find(@node.id).parameters[:foo].should == 'bar'
    end
  end

  describe 'validations' do
    before :each do
      @node = Node.new
    end

    it 'should require a name' do
      @node.name = nil
      @node.valid?
      @node.errors.should be_invalid(:name)
    end
    
    it 'should require name to be unique' do
      dup = Node.generate!(:name => 'unoriginal name')
      @node.name = 'unoriginal name'
      @node.valid?
      @node.errors.should be_invalid(:name)
    end

    it 'should be valid with an unique name' do
      @node.name = 'creative name'
      @node.valid?
      @node.errors.should_not be_invalid(:name)
    end
  end
  
  describe 'associations' do
    it 'should have services' do
      Node.new.should respond_to(:services)
    end
    
    it 'should allow setting and returning services' do
      @node = Node.new
      @services = Array.new(3) { Service.generate! }
      @node.services << @services
      @node.services.should == @services
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
    
    it "should return the names of the node's services in the returned class list" do
      @node.services = @services = Array.new(3) { Service.generate! }
      @node.configuration['classes'].sort.should == @services.collect(&:name).sort
    end
    
    it "should return the node's parameters in the returned parameters list" do
      @node.parameters = {'a' => 'b', 'c' => 'd'}
      @node.configuration['parameters'].should == { 'a' => 'b', 'c' => 'd' }  
    end
  end
end
