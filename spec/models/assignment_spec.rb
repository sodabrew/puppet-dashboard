require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Assignment do
  describe 'attributes' do
    before :each do
      @assignment = Assignment.new
    end
    
    it 'should have a service id' do
      @assignment.should respond_to(:service_id)
    end
    
    it 'should allow setting and retrieving the service id' do
      @assignment.service_id = 1
      @assignment.service_id.should == 1
    end

    it 'should have a node id' do
      @assignment.should respond_to(:node_id)
    end
    
    it 'should allow setting and retrieving the node id' do
      @assignment.node_id = 1
      @assignment.node_id.should == 1
    end
  end
  
  describe 'validations' do
    before :each do
      @assignment = Assignment.new
    end
    
    it 'should not be valid without a service' do
      @assignment.service = nil
      @assignment.valid?
      @assignment.errors.should be_invalid(:service)
    end

    it 'should be valid with a service' do
      @assignment.service = Service.generate!
      @assignment.valid?
      @assignment.errors.should_not be_invalid(:service)
    end

    it 'should not be valid without a node' do
      @assignment.node = nil
      @assignment.valid?
      @assignment.errors.should be_invalid(:node)
    end

    it 'should be valid with a node' do
      @assignment.node = Node.generate!
      @assignment.valid?
      @assignment.errors.should_not be_invalid(:node)
    end
  end
  
  describe 'relationships' do
    before :each do
      @assignment = Assignment.new
    end
    
    it 'should belong to a service' do
      @assignment.should respond_to(:service)
    end

    it 'should allow assigning the service' do
      @service = Service.generate!
      @assignment.service = @service
      @assignment.service.should == @service
    end
    
    it 'should belong to a node' do
      @assignment.should respond_to(:node)
    end

    it 'should allow assigning the node' do
      @node = Node.generate!
      @assignment.node = @node
      @assignment.node.should == @node
    end
  end
end
