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

    it 'should have a host id' do
      @assignment.should respond_to(:host_id)
    end
    
    it 'should allow setting and retrieving the host id' do
      @assignment.host_id = 1
      @assignment.host_id.should == 1
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

    it 'should not be valid without a host' do
      @assignment.host = nil
      @assignment.valid?
      @assignment.errors.should be_invalid(:host)
    end

    it 'should be valid with a host' do
      @assignment.host = Host.generate!
      @assignment.valid?
      @assignment.errors.should_not be_invalid(:host)
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
    
    it 'should belong to a host' do
      @assignment.should respond_to(:host)
    end

    it 'should allow assigning the host' do
      @host = Host.generate!
      @assignment.host = @host
      @assignment.host.should == @host
    end
  end
end
