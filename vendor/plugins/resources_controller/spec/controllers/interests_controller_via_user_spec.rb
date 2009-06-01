require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module InterestsViaUserSpecHelper
  def setup_mocks
    @user = mock('User')
    @user_interests = mock('user_interests assoc')
    User.stub!(:find_by_login).and_return(@user)
    @user.stub!(:interests).and_return(@user_interests)
    @user.stub!(:to_param).and_return('dave')
  end
end

describe "Routing shortcuts for Interests via User (users/dave/interests/2) should map" do
  include InterestsViaUserSpecHelper
  controller_name :interests
  
  before(:each) do
    setup_mocks
    @interest = mock('Interest')
    @interest.stub!(:to_param).and_return('2')
    @user_interests.stub!(:find).and_return(@interest)
    
    get :show, :user_id => "dave", :id => "2"
  end
  
  it "resources_path to /users/dave/interests" do
    controller.resources_path.should == '/users/dave/interests'
  end

  it "resource_path to /users/dave/interests/2" do
    controller.resource_path.should == '/users/dave/interests/2'
  end
  
  it "resource_path(9) to /users/dave/interests/9" do
    controller.resource_path(9).should == '/users/dave/interests/9'
  end

  it "edit_resource_path to /users/dave/interests/2/edit" do
    controller.edit_resource_path.should == '/users/dave/interests/2/edit'
  end
  
  it "edit_resource_path(9) to /users/dave/interests/9/edit" do
    controller.edit_resource_path(9).should == '/users/dave/interests/9/edit'
  end
  
  it "new_resource_path to /users/dave/interests/new" do
    controller.new_resource_path.should == '/users/dave/interests/new'
  end
end

describe "resource_service in InterestsController via Forum" do
  controller_name :interests
  
  before(:each) do
    @user           = User.create :login => 'dave'
    @interest       = Interest.create :interested_in_id => @user.id, :interested_in_type => 'User'
    @other_user     = User.create
    @other_interest = Interest.create :interested_in_id => @other_user.id, :interested_in_type => 'User'
    
    get :index, :user_id => @user.login
    @resource_service = controller.send :resource_service
  end
  
  it "should build new interest with @user fk and type with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Interest)
    resource.interested_in_id.should == @user.id
    resource.interested_in_type.should == 'User'
  end
  
  it "should find @interest with find(@interest.id)" do
    resource = @resource_service.find(@interest.id)
    resource.should == @interest
  end
  
  it "should raise RecordNotFound with find(@other_interest.id)" do
    lambda{ @resource_service.find(@other_interest.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only interests belonging to @user with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Interest.find(:all, :conditions => "interested_in_id = #{@user.id} AND interested_in_type = 'User'")
  end
end

describe "Requesting /users/dave/interests using GET" do
  include InterestsViaUserSpecHelper
  controller_name :interests

  before(:each) do
    setup_mocks
    @interests = mock('Interests')
    @user_interests.stub!(:find).and_return(@interests)
  end
  
  def do_get
    get :index, :user_id => "dave"
  end

  it "should find the user" do
    User.should_receive(:find_by_login).with('dave').and_return(@user)
    do_get
  end

  it "should assign the found user as :interested_in for the view" do
    do_get
    assigns[:interested_in].should == @user
  end

  it "should assign the user_interests association as the interests resource_service" do
    @user.should_receive(:interests).and_return(@user_interests)
    do_get
    @controller.resource_service.should == @user_interests
  end
end