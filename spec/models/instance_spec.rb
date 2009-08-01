require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Instance do
  describe 'attributes' do
    before :each do
      @instance = Instance.new
    end

    it 'can have a name' do
      @instance.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @instance.name = 'Test Instance'
      @instance.name.should == 'Test Instance'
    end
    
    it 'can be active' do
      @instance.should respond_to(:is_active)
    end
    
    it 'should allow setting and retrieving the active status' do
      @instance.is_active = true
      @instance.is_active.should be_true
    end
    
    it 'should have an app id' do
      @instance.should respond_to(:app_id)
    end
    
    it 'should allow setting and retrieving the app id' do
      @instance.app_id = 1
      @instance.app_id.should == 1
    end

    it 'should have a service id' do
      @instance.should respond_to(:service_id)
    end
    
    it 'should allow setting and retrieving the service id' do
      @instance.service_id = 1
      @instance.service_id.should == 1
    end
  end
  
  describe 'validations' do
    before :each do
      @instance = Instance.new
    end
    
    it 'should not be valid without an app' do
      @instance.app = nil
      @instance.valid?
      @instance.errors.should be_invalid(:app)
    end

    it 'should be valid with an app' do
      @instance.app = App.generate!
      @instance.valid?
      @instance.errors.should_not be_invalid(:app)
    end
  end
  
  describe 'relationships' do
    before :each do
      @instance = Instance.new
    end
    
    it 'should belong to an app' do
      @instance.should respond_to(:app)
    end

    it 'should allow assigning the app' do
      @app = App.generate!
      @instance.app = @app
      @instance.app.should == @app
    end
    
    it 'should belong to a service' do
      @instance.should respond_to(:service)
    end
    
    it 'should allow assigning the service' do
      @service = Service.generate!
      @instance.service = @service
      @instance.service.should == @service
    end
    
    it 'should have many deployments' do
      @instance.should respond_to(:deployments)
    end
    
    it 'should allow assigning deployments' do
      @deployment = Deployment.generate!
      @instance.deployments << @deployment
      @instance.deployments.should include(@deployment)
    end
  end
end
