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
    
    it 'should have an app id' do
      @deployment.should respond_to(:app_id)
    end
    
    it 'should allow setting and retrieving the app id' do
      @deployment.app_id = 1
      @deployment.app_id.should == 1
    end
  end
  
  describe 'validations' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should not be valid without an app' do
      @deployment.app = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:app)
    end

    it 'should be valid with a app' do
      @deployment.app = App.generate!
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:app)
    end
  end
  
  describe 'relationships' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should belong to an app' do
      @deployment.should respond_to(:app)
    end

    it 'should allow assigning the app' do
      @app = App.generate!
      @deployment.app = @app
      @deployment.app.should == @app
    end
  end
end
