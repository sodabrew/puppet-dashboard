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
  end
end
