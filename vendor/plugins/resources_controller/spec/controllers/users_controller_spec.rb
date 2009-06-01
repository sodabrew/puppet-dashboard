require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe UsersController, "#route_for" do

  it "should map { :controller => 'users', :action => 'index' } to /users" do
    route_for(:controller => "users", :action => "index").should == "/users"
  end
  
  it "should map { :controller => 'users', :action => 'new' } to /users/new" do
    route_for(:controller => "users", :action => "new").should == "/users/new"
  end
  
  it "should map { :controller => 'users', :action => 'show', :id => 'dave' } to /users/dave" do
    route_for(:controller => "users", :action => "show", :id => 'dave').should == "/users/dave"
  end
  
  it "should map { :controller => 'users', :action => 'edit', :id => 'dave' } to /users/dave/edit" do
    route_for(:controller => "users", :action => "edit", :id => 'dave').should == "/users/dave/edit"
  end
  
  it "should map { :controller => 'users', :action => 'update', :id => 'dave'} to PUT /users/dave" do
    route_for(:controller => "users", :action => "update", :id => 'dave').should == {:method => :put, :path => "/users/dave"}
  end
  
  it "should map { :controller => 'users', :action => 'destroy', :id => 'dave'} to DELETE /users/dave" do
    route_for(:controller => "users", :action => "destroy", :id => 'dave').should == {:method => :delete, :path => "/users/dave"}
  end
  
end

describe UsersController, "#params_from" do

  it "should generate params { :controller => 'users', action => 'index' } from GET /users" do
    params_from(:get, "/users").should == {:controller => "users", :action => "index"}
  end
  
  it "should generate params { :controller => 'users', action => 'new' } from GET /users/new" do
    params_from(:get, "/users/new").should == {:controller => "users", :action => "new"}
  end
  
  it "should generate params { :controller => 'users', action => 'create' } from POST /users" do
    params_from(:post, "/users").should == {:controller => "users", :action => "create"}
  end
  
  it "should generate params { :controller => 'users', action => 'show', id => '1' } from GET /users/dave" do
    params_from(:get, "/users/dave").should == {:controller => "users", :action => "show", :id => "dave"}
  end
  
  it "should generate params { :controller => 'users', action => 'edit', id => '1' } from GET /users/dave;edit" do
    params_from(:get, "/users/dave/edit").should == {:controller => "users", :action => "edit", :id => "dave"}
  end
  
  it "should generate params { :controller => 'users', action => 'update', id => '1' } from PUT /users/dave" do
    params_from(:put, "/users/dave").should == {:controller => "users", :action => "update", :id => "dave"}
  end
  
  it "should generate params { :controller => 'users', action => 'destroy', id => '1' } from DELETE /users/dave" do
    params_from(:delete, "/users/dave").should == {:controller => "users", :action => "destroy", :id => "dave"}
  end
  
end

describe UsersController, "handling GET /users" do

  before do
    @user = mock_model(User)
    User.stub!(:find).and_return([@user])
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all users" do
    User.should_receive(:find).with(:all).and_return([@user])
    do_get
  end
  
  it "should assign the found users for the view" do
    do_get
    assigns[:users].should == [@user]
  end
end

describe UsersController, "handling GET /users.xml" do

  before do
    @user = mock_model(User, :to_xml => "XML")
    User.stub!(:find).and_return(@user)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all users" do
    User.should_receive(:find).with(:all).and_return([@user])
    do_get
  end
  
  it "should render the found users as xml" do
    @user.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe UsersController, "handling GET /users/dave" do

  before do
    @user = mock_model(User)
    User.stub!(:find_by_login).and_return(@user)
  end
  
  def do_get
    get :show, :id => "dave"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show template" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_login).with("dave").and_return(@user)
    do_get
  end
  
  it "should assign the found user for the view" do
    do_get
    assigns[:user].should equal(@user)
  end
end

describe UsersController, "handling GET /users/dave.xml" do

  before do
    @user = mock_model(User, :to_xml => "XML")
    User.stub!(:find_by_login).and_return(@user)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "dave"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_login).with("dave").and_return(@user)
    do_get
  end
  
  it "should render the found user as xml" do
    @user.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe UsersController, "handling GET /users/new" do
  it "should be unknown action" do
    lambda{ get :new }.should raise_error(ActionController::UnknownAction)
  end
end

describe UsersController, "handling GET /users/dave/edit" do

  before do
    @user = mock_model(User)
    User.stub!(:find_by_login).and_return(@user)
  end
  
  def do_get
    get :edit, :id => "dave"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_login).and_return(@user)
    do_get
  end
  
  it "should assign the found User for the view" do
    do_get
    assigns[:user].should equal(@user)
  end
end

describe UsersController, "handling POST /users" do
  it "should be unknown action" do
    lambda{ post :create }.should raise_error(ActionController::UnknownAction)
  end
end

describe UsersController, "handling PUT /users/dave" do

  before do
    @user = mock_model(User, :to_param => "dave")
    User.stub!(:find_by_login).and_return(@user)
  end
  
  def put_with_successful_update
    @user.should_receive(:update_attributes).and_return(true)
    put :update, :id => "dave"
  end
  
  def put_with_failed_update
    @user.should_receive(:update_attributes).and_return(false)
    put :update, :id => "dave"
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_login).with("dave").and_return(@user)
    put_with_successful_update
  end

  it "should update the found user" do
    put_with_successful_update
    assigns(:user).should equal(@user)
  end

  it "should assign the found user for the view" do
    put_with_successful_update
    assigns(:user).should equal(@user)
  end

  it "should redirect to the user on successful update" do
    put_with_successful_update
    response.should redirect_to(user_url("dave"))
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe UsersController, "handling DELETE /users/dave" do
  it "should be unknown action" do
    lambda{ delete :destroy, :id => "dave" }.should raise_error(ActionController::UnknownAction)
  end
end
