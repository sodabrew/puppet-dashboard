require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Edge do
  before :each do
    @edge = Edge.new
  end

  describe 'attributes' do
    it 'should have a source_id' do
      @edge.should respond_to(:source_id)
    end

    it 'should have a target_id' do
      @edge.should respond_to(:target_id)
    end
  end

  describe 'associations' do
    it 'should have a source' do
      @edge.should respond_to(:source)
    end

    it 'should allow assigning source' do
      @service = Service.generate!
      @edge.source = @service
      @edge.source.should == @service
    end
    
    it 'should have a target' do
      @edge.should respond_to(:target)
    end

    it 'should allow assigning target' do
      @service = Service.generate!
      @edge.target = @service
      @edge.target.should == @service
    end
  end
  
  describe 'validations' do
    it 'should not be valid without a source' do
      @edge.source = nil
      @edge.valid?
      @edge.errors.should be_invalid(:source)
    end

    it 'should be valid with a source' do
      @edge.source = Service.generate!
      @edge.valid?
      @edge.errors.should_not be_invalid(:source)
    end
    
    it 'should not be valid without a target' do
      @edge.target = nil
      @edge.valid?
      @edge.errors.should be_invalid(:target)
    end

    it 'should be valid with a target' do
      @edge.target = Service.generate!
      @edge.valid?
      @edge.errors.should_not be_invalid(:target)
    end
  end
end
