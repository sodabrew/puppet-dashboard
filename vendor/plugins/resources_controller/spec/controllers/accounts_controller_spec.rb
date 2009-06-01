require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module AccountsControllerSpecHelper
  def setup_mocks
    @current_user = mock('user')
    @current_user.stub!(:id).and_return('1')
    User.stub!(:find).and_return(@current_user)
    @controller.instance_variable_set('@current_user', @current_user)
  end
end

describe "Routing shortcuts for Account should map" do
  include AccountsControllerSpecHelper
  controller_name :accounts
  
  before(:each) do
    setup_mocks
    get :show
  end

  it "resource_path to /account" do
    controller.resource_path.should == '/account'
  end
   
  it "resource_info_tags_path to /account/info/tags" do
    controller.resource_info_tags_path.should == "/account/info/tags"
  end    
end

describe AccountsController, "#resource_service" do
  include AccountsControllerSpecHelper
  controller_name :accounts
  
  before(:each) do
    setup_mocks 
    get :show
    @resource_service = controller.send :resource_service
  end
  
  it ".new should call :new on User" do
    User.should_receive(:new).with(:args => 'args')
    @resource_service.new :args => 'args'
  end
  
  it ".find should call :current_user" do
    @controller.should_receive(:current_user).once.and_return(@current_user)
    @resource_service.find
  end
  
  it ".find should call whatever is in resource_specification @find" do
    @controller.should_receive(:lambda_called).once.and_return(@current_user)
    @controller.send(:resource_specification).stub!(:find).and_return(lambda { lambda_called })
    @resource_service.find
  end
  
  it ".find should raise CantFindSingleton when no custom finder (and no enclosing resource)" do
    @controller.send(:resource_specification).stub!(:find).and_return nil
    lambda{ @resource_service.find }.should raise_error(Ardes::ResourcesController::CantFindSingleton)
  end
  
  it ".foo should call foo on User" do
    User.should_receive(:foo).once
    @resource_service.foo
  end
  
  it ".respond_to?(:foo) should call respond_to?(:foo) on User" do
    User.stub!(:foo)
    @resource_service.respond_to?(:foo).should be_true
  end
end