require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Requirement do
  describe 'attributes' do
    before :each do
      @requirement = Requirement.new
    end
    
    it 'should have a service id' do
      @requirement.should respond_to(:service_id)
    end
    
    it 'should allow setting and retrieving the service id' do
      @requirement.service_id = 1
      @requirement.service_id.should == 1
    end

    it 'should have an instance id' do
      @requirement.should respond_to(:instance_id)
    end

    it 'should allow setting and retrieving the instance id' do
      @requirement.instance_id = 1
      @requirement.instance_id.should == 1
    end
  end

  describe 'validations' do
    before :each do
      @requirement = Requirement.new
    end

    it 'should not be valid without a service' do
      @requirement.service = nil
      @requirement.valid?
      @requirement.errors.should be_invalid(:service)
    end
    
    it 'should be valid with a service' do
      @requirement.service = Service.generate!
      @requirement.valid?
      @requirement.errors.should_not be_invalid(:service)
    end
    
    it 'should not be valid without an instance' do
      @requirement.instance = nil
      @requirement.valid?
      @requirement.errors.should be_invalid(:instance)
    end

    it 'should be valid with a customer' do
      @requirement.instance = Instance.generate!
      @requirement.valid?
      @requirement.errors.should_not be_invalid(:instance)
    end  
  end
  
  describe 'relationships' do
    before :each do
      @requirement = Requirement.new
    end
    
    it 'should belong to a service' do
      @requirement.should respond_to(:service)
    end

    it 'should allow assigning service' do
      @service = Service.generate!
      @requirement.service = @service
      @requirement.service.should == @service
    end

    it 'should belong to an instance' do
      @requirement.should respond_to(:instance)
    end

    it 'should allow assigning service' do
      @instance = Instance.generate!
      @requirement.instance = @instance
      @requirement.instance.should == @instance
    end
  end
end
