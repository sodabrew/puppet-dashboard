require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Deployment do
  describe 'attributes' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'can be active' do
      @deployment.should respond_to(:is_active)
    end
    
    it 'should allow setting and retrieving the active status' do
      @deployment.is_active = true
      @deployment.is_active.should be_true
    end
    
    it 'should have an instance id' do
      @deployment.should respond_to(:instance_id)
    end
    
    it 'should allow setting and retrieving the instance id' do
      @deployment.instance_id = 1
      @deployment.instance_id.should == 1
    end

    it 'should have a host id' do
      @deployment.should respond_to(:host_id)
    end
    
    it 'should allow setting and retrieving the host id' do
      @deployment.host_id = 1
      @deployment.host_id.should == 1
    end
  end
  
  describe 'validations' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should not be valid without an instance' do
      @deployment.instance = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:instance)
    end

    it 'should be valid with an instance' do
      @deployment.instance = Instance.generate!
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:instance)
    end

    it 'should not be valid without a host' do
      @deployment.host = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:host)
    end

    it 'should be valid with a host' do
      @deployment.host = Host.generate!
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:host)
    end
  end
  
  describe 'relationships' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should belong to an instance' do
      @deployment.should respond_to(:instance)
    end

    it 'should allow assigning the instance' do
      @instance = Instance.generate!
      @deployment.instance = @instance
      @deployment.instance.should == @instance
    end
    
    it 'should belong to a host' do
      @deployment.should respond_to(:host)
    end

    it 'should allow assigning the host' do
      @host = Host.generate!
      @deployment.host = @host
      @deployment.host.should == @host
    end
    
    it 'should have an app' do
      @deployment.should respond_to(:app)
    end
    
    it "should return the instance's app" do
      @deployment = Deployment.generate!
      @deployment.app.should == @deployment.instance.app
    end
    
    it 'should have a customer' do
      @deployment.should respond_to(:customer)
    end
    
    it "should return the app's customer" do
      @deployment = Deployment.generate!
      @deployment.customer.should == @deployment.app.customer
    end
    
    it 'should have a service' do
      @deployment.should respond_to(:service)
    end
    
    it "should return the instance's service when looking up the service" do
      @deployment = Deployment.generate!
      @deployment.service.should == @deployment.instance.service
    end
    
    it 'should have required services' do
      @deployment.should respond_to(:required_services)
    end
    
    it 'should return the required services for the instance when looking up the service' do
      @deployment = Deployment.generate!
      @deployment.required_services.should == @deployment.instance.required_services
    end
    
  end
end
