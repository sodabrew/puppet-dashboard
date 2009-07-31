require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Watcher do
  describe 'attributes' do
    before :each do
      @watcher = Watcher.new
    end
    
    it 'can be active' do
      @watcher.should respond_to(:is_active)
    end
    
    it 'should allow setting and retrieving the active status' do
      @watcher.is_active = true
      @watcher.is_active.should be_true
    end
  end
end
