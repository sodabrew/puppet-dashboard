require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Destination do
  describe 'attributes' do
    before :each do
      @destination = Destination.new
    end
    
    it 'can be active' do
      @destination.should respond_to(:is_active)
    end
    
    it 'should allow setting and retrieving the active status' do
      @destination.is_active = true
      @destination.is_active.should be_true
    end
  end
end
