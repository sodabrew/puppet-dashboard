require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe App do
  describe 'attributes' do
    before :each do
      @app = App.new
    end
    
    it 'should have a name' do
      @app.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @app.name = 'test name'
      @app.name.should == 'test name'
    end

    it 'should have a description' do
      @app.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @app.description = 'test description'
      @app.description.should == 'test description'
    end
    
    it 'should have a customer id' do
      @app.should respond_to(:customer_id)
    end
    
    it 'should allow setting and retrieving the customer id' do
      @app.customer_id = 1
      @app.customer_id.should == 1
    end
  end

  describe 'validations' do
    before :each do
      @app = App.new
    end

    it 'should require a name' do
      @app.name = nil
      @app.valid?
      @app.errors.should be_invalid(:name)
    end
    
    it 'should be valid with a name' do
      @app.name = 'Test Name'
      @app.valid?
      @app.errors.should_not be_invalid(:name)
    end
    
    it 'should not be valid without a customer' do
      @app.customer = nil
      @app.valid?
      @app.errors.should be_invalid(:customer)
    end

    it 'should be valid with a customer' do
      @app.customer = Customer.generate!
      @app.valid?
      @app.errors.should_not be_invalid(:customer)
    end  
  end
  
  describe 'relationships' do
    before :each do
      @app = App.new
    end
    
    it 'should belong to a customer' do
      @app.should respond_to(:customer)
    end

    it 'should allow assigning customer' do
      @customer = Customer.generate!
      @app.customer = @customer
      @app.customer.should == @customer
    end
    
    it 'should have many deployable instances' do
      @app.should respond_to(:instances)
    end
    
    it 'should allow assigning deployable instances' do
      @instance = Instance.generate!
      @app.instances << @instance
      @app.instances.should include(@instance)
    end
    
    it 'should have many deployments' do
      @app.should respond_to(:deployments)
    end

    it 'should allow assigning deployments' do
      @deployment = Deployment.generate!
      @app.deployments << @deployment
      @app.deployments.should include(@deployment)
    end
    
    it 'should have many hosts' do
      @app.should respond_to(:hosts)
    end
    
    it 'should create hosts when making deployments' do
      @app = App.generate!
      @deployment = @app.deployments.generate!
      @app.hosts.should include(@deployment.host)
    end
  end
end
