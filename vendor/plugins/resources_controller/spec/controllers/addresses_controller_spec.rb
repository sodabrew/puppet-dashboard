require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module AddressesSpecHelper
  def setup_mocks
    @user = mock('User')
    @user_addresses = mock('Assoc: user_addresses')
    @user.stub!(:addresses).and_return(@user_addresses)
    @user.stub!(:to_param).and_return("dave")
    
    User.stub!(:find_by_login).and_return(@user)
  end
end

describe "Routing shortcuts for Addresses (users/dave/addresses/1) should map" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('Address')
    @address.stub!(:to_param).and_return('1')
    @user_addresses.stub!(:find).and_return(@address)
  
    get :show, :user_id => "dave", :id => "1"
  end
  
  it "resources_path to /users/dave/addresses" do
    controller.resources_path.should == '/users/dave/addresses'
  end

  it "resource_path to /users/dave/addresses/1" do
    controller.resource_path.should == '/users/dave/addresses/1'
  end
  
  it "resource_path(9) to /users/dave/addresses/9" do
    controller.resource_path(9).should == '/users/dave/addresses/9'
  end

  it "edit_resource_path to /users/dave/addresses/1/edit" do
    controller.edit_resource_path.should == '/users/dave/addresses/1/edit'
  end
  
  it "edit_resource_path(9) to /users/dave/addresses/9/edit" do
    controller.edit_resource_path(9).should == '/users/dave/addresses/9/edit'
  end
  
  it "new_resource_path to /users/dave/addresses/new" do
    controller.new_resource_path.should == '/users/dave/addresses/new'
  end
end

describe "resource_service in AddressesController" do
  controller_name :addresses
  
  before(:each) do
    @user          = User.create :login => 'dave'
    @address       = Address.create :user_id => @user.id
    @other_user    = User.create
    @other_address = Address.create :user_id => @other_user.id
    
    get :index, :user_id => 'dave'
    @resource_service = controller.send :resource_service
  end
  
  it "should build new address with @user foreign key with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Address)
    resource.user_id.should == @user.id
  end
  
  it "should find @address with find(@address.id)" do
    resource = @resource_service.find(@address.id)
    resource.should == @address
  end
  
  it "should raise RecordNotFound with find(@other_address.id)" do
    lambda{ @resource_service.find(@other_address.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only addresses belonging to @user with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Address.find(:all, :conditions => "user_id = #{@user.id}")
  end
end

describe "Requesting /users/dave/addresses" do
  include AddressesSpecHelper
  controller_name :addresses
  
  before(:each) do
    setup_mocks
    @addresses = mock('Addresses')
    @user_addresses.stub!(:find).and_return(@addresses)
  end
  
  def do_get
    get :index, :user_id => 'dave'
  end
    
  it "should find the user" do
    User.should_receive(:find_by_login).with('dave').and_return(@user)
    do_get
  end
  
  it "should assign the found user for the view" do
    do_get
    assigns[:user].should == @user
  end
  
  it "should assign the user_addresses association as the addresses resource_service" do
    @user.should_receive(:addresses).and_return(@user_addresses)
    do_get
    @controller.resource_service.should == @user_addresses
  end 
end

describe "Requesting /users/dave/addresses using GET" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @addresses = mock('Addresses')
    @user_addresses.stub!(:find).and_return(@addresses)
  end
  
  def do_get
    get :index, :user_id => '2'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index.rhtml" do
    do_get
    response.should render_template(:index)
  end
  
  it "should find all addresses" do
    @user_addresses.should_receive(:find).with(:all).and_return(@addresses)
    do_get
  end
  
  it "should assign the found addresses for the view" do
    do_get
    assigns[:addresses].should == @addresses
  end
end

describe "Requesting /users/dave/addresses/1 using GET" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('a address')
    @user_addresses.stub!(:find).and_return(@address)
  end
  
  def do_get
    get :show, :id => "1", :user_id => "dave"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show.rhtml" do
    do_get
    response.should render_template(:show)
  end
  
  it "should find the thing requested" do
    @user_addresses.should_receive(:find).with("1").and_return(@address)
    do_get
  end
  
  it "should assign the found thing for the view" do
    do_get
    assigns[:address].should == @address
  end
end

describe "Requesting /users/dave/addresses/new using GET" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('new Address')
    @user_addresses.stub!(:new).and_return(@address)
  end
  
  def do_get
    get :new, :user_id => "dave"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new.rhtml" do
    do_get
    response.should render_template(:new)
  end
  
  it "should create an new thing" do
    @user_addresses.should_receive(:new).and_return(@address)
    do_get
  end
  
  it "should not save the new thing" do
    @address.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new thing for the view" do
    do_get
    assigns[:address].should == @address
  end
end

describe "Requesting /users/dave/addresses/1/edit using GET" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('Address')
    @user_addresses.stub!(:find).and_return(@address)
  end
 
  def do_get
    get :edit, :id => "1", :user_id => "dave"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit.rhtml" do
    do_get
    response.should render_template(:edit)
  end
  
  it "should find the thing requested" do
    @user_addresses.should_receive(:find).with("1").and_return(@address)
    do_get
  end
  
  it "should assign the found Thing for the view" do
    do_get
    assigns(:address).should equal(@address)
  end
end

describe "Requesting /users/dave/addresses using POST" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('Address')
    @address.stub!(:save).and_return(true)
    @address.stub!(:to_param).and_return("1")
    @user_addresses.stub!(:new).and_return(@address)
  end
  
  def do_post
    post :create, :address => {:name => 'Address'}, :user_id => "dave"
  end
  
  it "should create a new address" do
    @user_addresses.should_receive(:new).with({'name' => 'Address'}).and_return(@address)
    do_post
  end

  it "should redirect to the new address" do
    do_post
    response.should be_redirect
    response.redirect_url.should == "http://test.host/users/dave/addresses/1"
  end
end

describe "Requesting /users/dave/addresses/1 using PUT" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('Address', :null_object => true)
    @address.stub!(:to_param).and_return("1")
    @user_addresses.stub!(:find).and_return(@address)
  end
  
  def do_update
    put :update, :id => "1", :user_id => "dave"
  end
  
  it "should find the address requested" do
    @user_addresses.should_receive(:find).with("1").and_return(@address)
    do_update
  end

  it "should update the found address" do
    @address.should_receive(:update_attributes).and_return(true)
    do_update
  end

  it "should assign the found address for the view" do
    do_update
    assigns(:address).should == @address
  end

  it "should redirect to the address" do
    do_update
    response.should be_redirect
    response.redirect_url.should == "http://test.host/users/dave/addresses/1"
  end
end

describe "Requesting /users/dave/addresses/1 using DELETE" do
  include AddressesSpecHelper
  controller_name :addresses

  before(:each) do
    setup_mocks
    @address = mock('Address', :null_object => true)
    @user_addresses.stub!(:find).and_return(@address)
  end
  
  def do_delete
    delete :destroy, :id => "1", :user_id => "dave"
  end

  it "should find the address requested" do
    @user_addresses.should_receive(:find).with("1").and_return(@address)
    do_delete
  end
  
  it "should call destroy on the found thing" do
    @address.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the things list" do
    do_delete
    response.should be_redirect
    response.redirect_url.should == "http://test.host/users/dave/addresses"
  end
end