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
    
    it 'should have a set of parameters' do
      @host.should respond_to(:parameters)
    end
    
    it 'should allow setting and retrieving parameter values' do
      @host.parameters = { :foo => 'bar' }
      @host.parameters[:foo].should == 'bar'
    end
    
    it 'should preserve parameters as a hash across saving' do
      @host = Host.generate!(:parameters => { :foo => 'bar'})
      Host.find(@host.id).parameters[:foo].should == 'bar'
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
  
  describe 'associations' do
    it 'should have services' do
      Host.new.should respond_to(:services)
    end
    
    it 'should allow setting and returning services' do
      @host = Host.new
      @services = Array.new(3) { Service.generate! }
      @host.services << @services
      @host.services.should == @services
    end
  end

  it 'should be able to compute a configuration' do
    Host.new.should respond_to(:configuration)
  end
  
  describe 'when computing a configuration' do
    before :each do
      @host = Host.generate!
    end
    
    it 'should work without arguments' do
      lambda { @host.configuration }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @host.configuration(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should return a set of classes and parameters' do
      @host.configuration.keys.sort.should == ['classes', 'parameters']
    end
    
    it "should return the names of the host's services in the returned class list" do
      @host.services = @services = Array.new(3) { Service.generate! }
      @host.configuration['classes'].sort.should == @services.collect(&:name).sort
    end
    
    it "should return the host's parameters in the returned parameters list" do
      @host.parameters = {'a' => 'b', 'c' => 'd'}
      @host.configuration['parameters'].should == { 'a' => 'b', 'c' => 'd' }  
    end
  end
end
