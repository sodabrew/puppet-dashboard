require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Audit do
  describe 'attributes' do
    before :each do
      @audit = Audit.new
    end

    it 'should be a kind of service' do
      @audit.should be_kind_of(Service)
    end

    it 'should have a name' do
      @audit.should respond_to(:name)
    end

    it 'should allow setting and retrieving the name' do
      @audit.name = 'test name'
      @audit.name.should == 'test name'
    end

    it 'should have a description' do
      @audit.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @audit.description = 'test description'
      @audit.description.should == 'test description'
    end
  end

  describe 'validations' do
    before :each do
      @audit = Audit.new
    end

    it 'should require a name' do
      @audit.name = nil
      @audit.valid?
      @audit.errors.should be_invalid(:name)
    end
    
    it 'should require name to be unique' do
      dup = Audit.generate!(:name => 'unoriginal name')
      @audit.name = 'unoriginal name'
      @audit.valid?
      @audit.errors.should be_invalid(:name)
    end

    it 'should be valid with an unique name' do
      @audit.name = 'creative name'
      @audit.valid?
      @audit.errors.should_not be_invalid(:name)
    end
  end
end
