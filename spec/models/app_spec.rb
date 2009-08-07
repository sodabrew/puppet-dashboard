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
    
    it 'should allow return deployments from all instances' do
      @deployments = Array.new(2) { Deployment.generate! }
      @app.instances << @deployments.collect(&:instance)
      @app.deployments.sort_by(&:id).should == @deployments.sort_by(&:id)
    end
    
    it 'should have many hosts' do
      @app.should respond_to(:hosts)
    end
    
    it 'should include hosts for all deployed instances' do
      @deployments = Array.new(2) { Deployment.generate! }
      @app.instances << @deployments.collect(&:instance)
      @app.hosts.sort_by(&:id).should == @deployments.collect(&:host).flatten.sort_by(&:id)
    end
    
    it 'should have services' do
      @app.should respond_to(:services)
    end
    
    it 'should return the services from all instances when computing services' do
      @instances = Array.new(2) { Instance.generate! }
      @app.instances << @instances
      @app.services.sort_by(&:id).should == @instances.collect(&:services).flatten.sort_by(&:id)
    end
    
    it 'should have required services' do
      @instances = Array.new(2) { Instance.generate! }
      @app.instances << @instances
      @app.services.sort_by(&:id).should == @instances.collect(&:services).flatten.sort_by(&:id)      
    end
    
    it 'should return the required services from all its instances' do
      @service     = Service.generate!(:name => 'service')
      @parent      = Service.generate!(:name => 'parent')
      @grandparent = Service.generate!(:name => 'grandparent')
      @child       = Service.generate!(:name => 'child')
      @grandchild  = Service.generate!(:name => 'grandchild')
      @service.dependents << @parent
      @parent.dependents  << @grandparent
      @service.depends_on << @child
      @child.depends_on   << @grandchild
      
      @instance1 = Instance.generate!
      @instance1.services << @service
      @instance2 = Instance.generate!
      @instance2.services << @child
      
      @app.instances << [ @instance1, @instance2 ]
      
      @app.required_services.sort_by(&:id).should == [ @service, @child, @grandchild ].sort_by(&:id)
    end
  end
end
