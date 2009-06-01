require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "Routing shortcuts for Forums should map" do
  controller_name :forums
  
  before(:each) do
    @forum = mock('Forum')
    @forum.stub!(:to_param).and_return('2')
    Forum.stub!(:find).and_return(@forum)
    get :show, :id => "2"
  end
  
  it "resources_path to /forums" do
    controller.resources_path.should == '/forums'
  end

  it "resources_path(:foo => 'bar') to /forums?foo=bar" do
    controller.resources_path(:foo => 'bar').should == '/forums?foo=bar'
  end

  it "resource_path to /forums/2" do
    controller.resource_path.should == '/forums/2'
  end

  it "resource_path(:foo => 'bar') to /forums/2?foo=bar" do
    controller.resource_path(:foo => 'bar').should == '/forums/2?foo=bar'
  end
  
  it "resource_path(9) to /forums/9" do
    controller.resource_path(9).should == '/forums/9'
  end

  it "resource_path(9, :foo => 'bar') to /forums/2?foo=bar" do
    controller.resource_path(9, :foo => 'bar').should == '/forums/9?foo=bar'
  end

  it "edit_resource_path to /forums/2/edit" do
    controller.edit_resource_path.should == '/forums/2/edit'
  end
  
  it "edit_resource_path(9) to /forums/9/edit" do
    controller.edit_resource_path(9).should == '/forums/9/edit'
  end
  
  it "new_resource_path to /forums/new" do
    controller.new_resource_path.should == '/forums/new'
  end
  
  it "resources_url to http://test.host/forums" do
    controller.resources_url.should == 'http://test.host/forums'
  end

  it "resource_url to http://test.host/forums/2" do
    controller.resource_url.should == 'http://test.host/forums/2'
  end
  
  it "resource_url(9) to http://test.host/forums/9" do
    controller.resource_url(9).should == 'http://test.host/forums/9'
  end

  it "edit_resource_url to http://test.host/forums/2/edit" do
    controller.edit_resource_url.should == 'http://test.host/forums/2/edit'
  end
  
  it "edit_resource_url(9) to http://test.host/forums/9/edit" do
    controller.edit_resource_url(9).should == 'http://test.host/forums/9/edit'
  end
  
  it "new_resource_url to http://test.host/forums/new" do
    controller.new_resource_url.should == 'http://test.host/forums/new'
  end
 
  it "resource_interests_path to /forums/2/interests" do
    controller.resource_interests_path.should == "/forums/2/interests"
  end
  
  it "resource_interests_path(:foo => 'bar') to /forums/2/interests?foo=bar" do
    controller.resource_interests_path(:foo => 'bar').should == '/forums/2/interests?foo=bar'
  end
  
  it "resource_interests_path(9) to /forums/9/interests" do
    controller.resource_interests_path(9).should == "/forums/9/interests"
  end
  
  it "resource_interests_path(9, :foo => 'bar') to /forums/9/interests?foo=bar" do
    controller.resource_interests_path(9, :foo => 'bar').should == "/forums/9/interests?foo=bar"
  end

  it "resource_interest_path(5) to /forums/2/interests/5" do
    controller.resource_interest_path(5).should == "/forums/2/interests/5"
  end
  
  it "resource_interest_path(9,5) to /forums/9/interests/5" do
    controller.resource_interest_path(9,5).should == "/forums/9/interests/5"
  end
  
  it "resource_interest_path(9,5, :foo => 'bar') to /forums/9/interests/5?foo=bar" do
    controller.resource_interest_path(9, 5, :foo => 'bar').should == "/forums/9/interests/5?foo=bar"
  end

  it 'new_resource_interest_path(9) to /forums/9/interests/new' do
    controller.new_resource_interest_path(9).should == "/forums/9/interests/new"
  end
  
  it 'edit_resource_interest_path(5) to /forums/2/interests/5/edit' do
    controller.edit_resource_interest_path(5).should == "/forums/2/interests/5/edit"
  end
  
  it 'edit_resource_interest_path(9,5) to /forums/9/interests/5/edit' do
    controller.edit_resource_interest_path(9,5).should == "/forums/9/interests/5/edit"
  end
  
  it "respond_to?(:edit_resource_interest_path) should == true" do
    controller.should respond_to(:edit_resource_interest_path)
  end

  it "resource_users_path should raise informative NoMethodError" do
    lambda{ controller.resource_users_path }.should raise_error(Ardes::ResourcesController::CantMapRoute, <<-end_str
Tried to map :resource_users_path to :forum_users_path,
which doesn't exist. You may not have defined the route in config/routes.rb.

Or, if you have unconventianal route names or name prefixes, you may need
to explicictly set the :route option in resources_controller_for, and set
the :name_prefix option on your enclosing resources.

Currently:
  :route is 'forum'
  generated name_prefix is ''
end_str
    )
  end
  
  it "enclosing_resource_path should raise informative NoMethodError" do
    lambda{ controller.enclosing_resource_path }.should raise_error(NoMethodError, "Tried to map :enclosing_resource_path but there is no enclosing_resource for this controller")
  end
  
  it "any_old_missing_method should raise NoMethodError" do
    lambda{ controller.any_old_missing_method }.should raise_error(NoMethodError)
  end
  
  it "respond_to?(:resource_users_path) should == false" do
    controller.should_not respond_to(:resource_users_path)
  end
end

describe ForumsController, " (checking that non actions are hidden)" do
  it "should only have CRUD actions as action_methods" do
    (@controller.class.send(:action_methods) & Set.new(['resource', 'resources'])).should be_empty
  end
end

describe "resource_service in ForumsController" do
  controller_name :forums
  
  before(:each) do
    @forum = Forum.create
    
    get :index
    @resource_service = controller.send :resource_service
  end
  
  it "should build new forum with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Forum)
  end
  
  it "should find @forum with find(@forum.id)" do
    resource = @resource_service.find(@forum.id)
    resource.should == @forum
  end

  it "should find all forums with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should == Forum.find(:all)
  end
end

describe ForumsController, " requesting / (testing resource_path)" do
  it "should generate params { :controller => 'forums', :action => 'index', :resource_path => '/forums' } from GET /" do
    params_from(:get, "/").should == { :controller => 'forums', :action => 'index', :resource_path => '/forums' }
  end
  
  before(:each) do
    @mock_forums = mock('forums')
    Forum.stub!(:find).and_return(@mock_forums)
  end
  
  def do_get
    get :index, :resource_path => '/forums'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index.rhtml" do
    do_get
    response.should render_template(:index)
  end
  
  it "should find all forums" do
    Forum.should_receive(:find).with(:all).and_return(@mock_forums)
    do_get
  end
  
  it "should assign the found forums for the view" do
    do_get
    assigns[:forums].should == @mock_forums
  end
end

describe ForumsController, " requesting /create_forum (testing resource_method)" do
  it "should generate params { :controller => 'forums', :action => 'create', :resource_path => '/forums', :resource_method => :post } from GET /create_forum" do
    params_from(:get, "/create_forum").should == { :controller => 'forums', :action => 'create', :resource_path => '/forums', :resource_method => :post }
  end
  
  before(:each) do
    @mock_forum = mock('Forum')
    @mock_forum.stub!(:save).and_return(true)
    @mock_forum.stub!(:to_param).and_return("1")
    Forum.stub!(:new).and_return(@mock_forum)
  end
  
  def do_post
    post :create, :forum => {:name => 'Forum'}, :resource_path => '/forums', :resource_method => :post
    
  end
  
  it "should create a new forum" do
    Forum.should_receive(:new).with({'name' => 'Forum'}).and_return(@mock_forum)
    do_post
  end

  it "should set the flash notice" do
    do_post
    flash[:notice].should == "Forum was successfully created."
  end

  it "should redirect to the new forum" do
    do_post
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/1"
  end
end

describe "Requesting /forums using GET" do
  controller_name :forums

  before(:each) do
    @mock_forums = mock('forums')
    Forum.stub!(:find).and_return(@mock_forums)
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index.rhtml" do
    do_get
    response.should render_template(:index)
  end
  
  it "should find all forums" do
    Forum.should_receive(:find).with(:all).and_return(@mock_forums)
    do_get
  end
  
  it "should assign the found forums for the view" do
    do_get
    assigns[:forums].should == @mock_forums
  end
end

describe "Requesting /forums.xml using GET" do
  controller_name :forums

  before(:each) do
    @mock_forums = mock('forums')
    @mock_forums.stub!(:to_xml).and_return("XML")
    Forum.stub!(:find).and_return(@mock_forums)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all forums" do
    Forum.should_receive(:find).with(:all).and_return(@mock_forums)
    do_get
  end
  
  it "should render the found forums as xml" do
    @mock_forums.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should eql("XML")
  end
end

describe "Requesting /forums using XHR GET" do
  controller_name :forums

  before(:each) do
    @mock_forums = mock('forums')
    Forum.stub!(:find).and_return(@mock_forums)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "text/javascript"
    xhr :get, :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all forums" do
    Forum.should_receive(:find).with(:all).and_return(@mock_forums)
    do_get
  end
  
  it "should render index.rjs" do
    do_get
    response.should render_template('index')
  end
end

describe "Requesting /forums/1 using GET" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_get
    get :show, :id => "1"
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
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_get
  end
  
  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @mock_forum
  end
end

describe "Requesting /forums/1.xml using GET" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    @mock_forum.stub!(:to_xml).and_return("XML")
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the forum requested" do
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_get
  end
  
  it "should render the found forum as xml" do
    @mock_forum.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should eql("XML")
  end
end

describe "Requesting /forums/1 using XHR GET" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_get
    xhr :get, :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show.rjs" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the forum requested" do
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_get
  end
  
  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @mock_forum
  end
end

describe "Requesting /forums/new using GET" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    Forum.stub!(:new).and_return(@mock_forum)
  end
  
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new.rhtml" do
    do_get
    response.should render_template(:new)
  end
  
  it "should create an new forum" do
    Forum.should_receive(:new).and_return(@mock_forum)
    do_get
  end
  
  it "should not save the new forum" do
    @mock_forum.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new forum for the view" do
    do_get
    assigns[:forum].should == @mock_forum
  end
end

describe "Requesting /forums/1/edit using GET" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_get
    get :edit, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit.rhtml" do
    do_get
    response.should render_template(:edit)
  end
  
  it "should find the forum requested" do
    Forum.should_receive(:find).and_return(@mock_forum)
    do_get
  end
  
  it "should assign the found Forum for the view" do
    do_get
    assigns(:forum).should equal(@mock_forum)
  end
end

describe "Requesting /forums using POST" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    @mock_forum.stub!(:save).and_return(true)
    @mock_forum.stub!(:to_param).and_return("1")
    Forum.stub!(:new).and_return(@mock_forum)
  end
  
  def do_post
    post :create, :forum => {:name => 'Forum'}
  end
  
  it "should create a new forum" do
    Forum.should_receive(:new).with({'name' => 'Forum'}).and_return(@mock_forum)
    do_post
  end

  it "should set the flash notice" do
    do_post
    flash[:notice].should == "Forum was successfully created."
  end

  it "should redirect to the new forum" do
    do_post
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/1"
  end
end

describe "Requesting /forums using XHR POST" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum')
    @mock_forum.stub!(:save).and_return(true)
    @mock_forum.stub!(:to_param).and_return("1")
    Forum.stub!(:new).and_return(@mock_forum)
  end
  
  def do_post
    xhr :post, :create, :forum => {:name => 'Forum'}
  end
  
  it "should create a new forum" do
    Forum.should_receive(:new).with({'name' => 'Forum'}).and_return(@mock_forum)
    do_post
  end

  it "should not set the flash notice" do
    do_post
    flash[:notice].should == nil
  end

  it "should render create.rjs" do
    do_post
    response.should render_template('create')
  end
  
  it "should render new.rjs if unsuccesful" do
    @mock_forum.stub!(:save).and_return(false)
    do_post
    response.should render_template('new')
  end
end

describe "Requesting /forums/1 using PUT" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum', :null_object => true)
    @mock_forum.stub!(:to_param).and_return("1")
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_update
    put :update, :id => "1"
  end
  
  it "should find the forum requested" do
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_update
  end

  it "should set the flash notice" do
    do_update
    flash[:notice].should == "Forum was successfully updated."
  end

  it "should update the found forum" do
    @mock_forum.should_receive(:update_attributes)
    do_update
    assigns(:forum).should == @mock_forum
  end

  it "should assign the found forum for the view" do
    do_update
    assigns(:forum).should == @mock_forum
  end

  it "should redirect to the forum" do
    do_update
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/1"
  end
end

describe "Requesting /forums/1 using XHR PUT" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum', :null_object => true)
    @mock_forum.stub!(:to_param).and_return("1")
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_update
    xhr :put, :update, :id => "1"
  end
  
  it "should find the forum requested" do
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_update
  end

  it "should update the found forum" do
    @mock_forum.should_receive(:update_attributes)
    do_update
    assigns(:forum).should == @mock_forum
  end

  it "should not set the flash notice" do
    do_update
    flash[:notice].should == nil
  end

  it "should assign the found forum for the view" do
    do_update
    assigns(:forum).should == @mock_forum
  end

  it "should render update.rjs" do
    do_update
    response.should render_template('update')
  end
  
  it "should render edit.rjs, on unsuccessful save" do
    @mock_forum.stub!(:update_attributes).and_return(false)
    do_update
    response.should render_template('edit')
  end
end

describe "Requesting /forums/1 using DELETE" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum', :null_object => true)
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the forum requested" do
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_delete
  end
  
  it "should call destroy on the found forum" do
    @mock_forum.should_receive(:destroy)
    do_delete
  end
  
  it "should set the flash notice" do
    do_delete
    flash[:notice].should == 'Forum was successfully destroyed.'
  end
  
  it "should redirect to the forums list" do
    do_delete
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums"
  end
end

describe "Requesting /forums/1 using XHR DELETE" do
  controller_name :forums

  before(:each) do
    @mock_forum = mock('Forum', :null_object => true)
    Forum.stub!(:find).and_return(@mock_forum)
  end
  
  def do_delete
    xhr :delete, :destroy, :id => "1"
  end

  it "should find the forum requested" do
    Forum.should_receive(:find).with("1").and_return(@mock_forum)
    do_delete
  end
  
  it "should not set the flash notice" do
    do_delete
    flash[:notice].should == nil
  end
  
  it "should call destroy on the found forum" do
    @mock_forum.should_receive(:destroy)
    do_delete
  end
  
  it "should render destroy.rjs" do
    do_delete
    response.should render_template('destroy')
  end
end
