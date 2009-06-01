require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module OwnersControllerSpecHelper
  def setup_mocks
    @forum = mock('forum')
    @forum.stub!(:id).and_return(2)
    @forum.stub!(:to_param).and_return('2')
    Forum.stub!(:find).and_return(@forum)
    @owner = mock_model(User)
    @forum.stub!(:owner).and_return(@owner)    
  end
end

describe "Routing shortcuts for ForumOwner should map" do
  include OwnersControllerSpecHelper
  controller_name :owners
  
  before(:each) do
    setup_mocks
    get :show, :forum_id => "2"
  end

  it "resource_path to /forums/2/owner" do
    controller.resource_path.should == '/forums/2/owner'
  end
  
  it "resource_path(:foo => 'bar') to /forums/2/owner?foo=bar" do
    controller.resource_path(:foo => 'bar').should == '/forums/2/owner?foo=bar'
  end
  
  it "edit_resource_path to /forums/2/owner/edit" do
    controller.edit_resource_path.should == '/forums/2/owner/edit'
  end
    
  it "new_resource_path to /forums/2/owner/new" do
    controller.new_resource_path.should == '/forums/2/owner/new'
  end
   
  it "resource_posts_path to /forums/2/owner/posts" do
    controller.resource_posts_path.should == "/forums/2/owner/posts"
  end
  
  it "resource_posts_path(:foo => 'bar') to /forums/2/owner/posts?foo=bar" do
    controller.resource_posts_path(:foo => 'bar').should == '/forums/2/owner/posts?foo=bar'
  end
  
  it "resource_post_path(5) to /forums/2/owner/posts/5" do
    controller.resource_post_path(5).should == "/forums/2/owner/posts/5"
  end
  
  it "enclosing_resource_path to /forums/2" do
    controller.enclosing_resource_path.should == "/forums/2"
  end
end

describe OwnersController, "#resource_service" do
  include OwnersControllerSpecHelper
  controller_name :owners
  
  before(:each) do
    setup_mocks 
    get :show, :forum_id => "2"
    @resource_service = controller.send :resource_service
  end
  
  it ".new should call :build_owner on @forum" do
    @forum.should_receive(:build_owner).with(:args => 'args')
    @resource_service.new :args => 'args'
  end
  
  it ".find should call :owner on @forum" do
    @forum.should_receive(:owner)
    @resource_service.find
  end
end

describe "Requesting /forums/2/owner using GET" do
  include OwnersControllerSpecHelper
  controller_name :owners

  before(:each) do
    setup_mocks
  end
  
  def do_get
    get :show, :forum_id => "2"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show.rhtml" do
    do_get
    response.should render_template(:show)
  end
  
  it "should find the forum requested" do
    Forum.should_receive(:find).with("2").and_return(@forum)
    do_get
  end
  
  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @forum
  end
  
  it "should find the owner from forum.owner" do
    @forum.should_receive(:owner).and_return(@owner)
    do_get
  end
  
  it "should assign the found owner for the view" do
    do_get
    assigns[:owner].should == @owner
  end
end

describe "Requesting /forums/2/owner/new using GET" do
  include OwnersControllerSpecHelper
  controller_name :owners

  before(:each) do
    setup_mocks
    @forum.stub!(:build_owner).and_return(@owner)
  end
  
  def do_get
    get :new, :forum_id => "2"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new.rhtml" do
    do_get
    response.should render_template(:new)
  end
  
  it "should build a new owner" do
    @forum.should_receive(:build_owner).and_return(@owner)
    do_get
  end
end

describe "Requesting /forums/2/owner/edit using GET" do
  include OwnersControllerSpecHelper
  controller_name :owners

  before(:each) do
    setup_mocks
  end
  
  def do_get
    get :edit, :forum_id => "2"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit.rhtml" do
    do_get
    response.should render_template(:edit)
  end
  
  it "should find the owner from forum.owner" do
    @forum.should_receive(:owner).and_return(@owner)
    do_get
  end
end

describe "Requesting /forums/2/owner using POST" do
  include OwnersControllerSpecHelper
  controller_name :owners

  before(:each) do
    setup_mocks
    @owner.stub!(:save).and_return(true)
    @owner.stub!(:to_param).and_return("1")
    @forum.stub!(:build_owner).and_return(@owner)
  end
  
  def do_post
    post :create, :forum_id => 2, :owner => {:name => 'Fred'}
  end
  
  it "should build a new owner" do
    @forum.should_receive(:build_owner).with({'name' => 'Fred'}).and_return(@owner)
    do_post
  end

  it "should set the flash notice" do
    do_post
    flash[:notice].should == "Owner was successfully created."
  end

  it "should redirect to the new owner" do
    do_post
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/2/owner"
  end
  
  it "should render new when post unsuccesful" do
    @owner.stub!(:save).and_return(false)
    do_post
    response.should render_template('new')
  end
end


describe "Requesting /forums/2/owner using PUT" do
  include OwnersControllerSpecHelper
  controller_name :owners

  before(:each) do
    setup_mocks
    @owner.stub!(:update_attributes).and_return(true)
  end
  
  def do_update
    put :update, :forum_id => "2", :owner => {:name => 'Fred'}
  end
  
  it "should find the owner from forum.owner" do
    @forum.should_receive(:owner).and_return(@owner)
    do_update
  end

  it "should set the flash notice" do
    do_update
    flash[:notice].should == "Owner was successfully updated."
  end

  it "should update the owner" do
    @owner.should_receive(:update_attributes).with('name' => 'Fred')
    do_update
  end

  it "should redirect to the owner" do
    do_update
    response.should redirect_to("http://test.host/forums/2/owner")
  end
end


describe "Requesting /forums/2/owner using DELETE" do
  include OwnersControllerSpecHelper
  controller_name :owners

  before(:each) do
    setup_mocks
    @owner.stub!(:destroy).and_return(@owner)
  end
  
  def do_delete
    delete :destroy, :forum_id => "2"
  end

  it "should find the owner from forum.owner" do
    @forum.should_receive(:owner).and_return(@owner)
    do_delete
  end
  
  it "should call destroy on the owner" do
    @owner.should_receive(:destroy).and_return(@owner)
    do_delete
  end
  
  it "should set the flash notice" do
    do_delete
    flash[:notice].should == 'Owner was successfully destroyed.'
  end
  
  it "should redirect to forums/2" do
    do_delete
    response.should redirect_to("http://test.host/forums/2")
  end
end

