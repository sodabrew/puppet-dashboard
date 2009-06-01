require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module InfosControllerSpecHelper
  def setup_mocks
    @current_user = mock('user')
    @current_user.stub!(:id).and_return('1')
    @controller.stub!(:current_user).and_return(@current_user)
    @info = mock('info')
    @info.stub!(:id).and_return('3')
    @current_user.stub!(:info).and_return(@info)
  end
end

describe "Routing shortcuts for Infos should map" do
  include InfosControllerSpecHelper
  controller_name :infos
  
  before(:each) do
    setup_mocks
    get :show
  end

  it "resource_path to /account/info" do
    controller.resource_path.should == '/account/info'
  end
  
  it "resource_tags_path to /account/info/tags" do
    controller.resource_tags_path.should == "/account/info/tags"
  end    
end

describe InfosController, " (its actions)" do
  include InfosControllerSpecHelper
  
  before do
    setup_mocks
  end
  
  it "should not have ['new', 'index', 'destroy', 'create'] in action_methods" do
    (@controller.class.send(:action_methods) & Set.new(['new', 'index', 'destroy', 'create'])).should be_empty
  end
  
  it "GET /account/info should be successful" do
    get :show
    response.should be_success
  end

  it "GET /account/info/edit should be successful" do
    get :edit
    response.should be_success
  end
  
  it "PUT /account/info should be successful" do
    @info.stub!(:update_attributes).and_return(true)
    put :update
    response.should be_redirect
  end
  
  it "GET /account/info/new should raise UnknownAction" do
    lambda { get :new }.should raise_error(ActionController::UnknownAction)
  end
  
  it "POST /account/info should raise UnknownAction" do
    lambda { post :create }.should raise_error(ActionController::UnknownAction)
  end

  it "DELETE /account/info/new should raise UnknownAction" do
    lambda { delete :destroy }.should raise_error(ActionController::UnknownAction)
  end
end