require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Deployment do
  describe 'attributes' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'can be active' do
      @deployment.should respond_to(:is_active)
    end
    
    it 'should allow setting and retrieving the active status' do
      @deployment.is_active = true
      @deployment.is_active.should be_true
    end
  end
end
