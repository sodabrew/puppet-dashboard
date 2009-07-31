require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Customer do
  describe 'attributes' do
    before :each do
      @customer = Customer.new
    end
    
    it 'should have a name' do
      @customer.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @customer.name = 'test name'
      @customer.name.should == 'test name'
    end

    it 'should have a description' do
      @customer.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @customer.description = 'test description'
      @customer.description.should == 'test description'
    end
  end

  describe 'validations' do
    before :each do
      @customer = Customer.new
    end

    it 'should require a name' do
      @customer.name = nil
      @customer.valid?
      @customer.errors.should be_invalid(:name)
    end
    
    it 'should require name to be unique' do
      dup = Customer.generate!(:name => 'unoriginal name')
      @customer.name = 'unoriginal name'
      @customer.valid?
      @customer.errors.should be_invalid(:name)
    end

    it 'should be valid with an unique name' do
      @customer.name = 'creative name'
      @customer.valid?
      @customer.errors.should_not be_invalid(:name)
    end
  end
  
  describe 'relationships' do
    before :each do
      @customer = Customer.new
    end
    
    it 'should have many apps' do
      @customer.should respond_to(:apps)
    end

    it 'should allow assigning apps' do
      @customer = Customer.generate!
      @customer.apps.generate!
      @customer.apps.should_not be_empty
    end
    
    it 'should have many hosts' do
      @customer.should respond_to(:hosts)
    end
    
    it 'should create hosts when deploying customer apps' do
      @customer = Customer.generate!
      @app = @customer.apps.generate!
      @deployment = Deployment.generate!(:app => @app)
      @customer.hosts.should include(@deployment.host)
    end
  end
end
