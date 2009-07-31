require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Host do
  describe 'attributes' do
    before :each do
      @host = Host.new
    end
    
    it 'should have a name' do
      @host.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @host.name = 'test name'
      @host.name.should == 'test name'
    end

    it 'should have a description' do
      @host.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @host.description = 'test description'
      @host.description.should == 'test description'
    end
  end

  describe 'validations' do
    before :each do
      @host = Host.new
    end

    it 'should require a name' do
      @host.name = nil
      @host.valid?
      @host.errors.should be_invalid(:name)
    end
    
    it 'should require name to be unique' do
      dup = Host.generate!(:name => 'unoriginal name')
      @host.name = 'unoriginal name'
      @host.valid?
      @host.errors.should be_invalid(:name)
    end

    it 'should be valid with an unique name' do
      @host.name = 'creative name'
      @host.valid?
      @host.errors.should_not be_invalid(:name)
    end
  end

  describe 'relationships' do
    before :each do
      @host = Host.new
    end

    it 'should have many deployments' do
      @host.should respond_to(:deployments)
    end

    it 'should allow assigning deployments' do
      @deployment = Deployment.generate!
      @host.deployments << @deployment
      @host.deployments.should include(@deployment)
    end
    
    it 'should have many apps' do
      @host.should respond_to(:apps)
    end
    
    it 'should create apps when making deployments' do
      @host = Host.generate!
      @deployment = @host.deployments.generate!
      @host.apps.should include(@deployment.app)
    end
  end
end
