require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module TagsViaAccountInfoHelper
  def setup_mocks
    @current_user = mock('user')
    @current_user.stub!(:id).and_return('1')
    User.stub!(:find).and_return(@current_user)
    @info = mock('info')
    @info.stub!(:id).and_return('3')
    @current_user.stub!(:info).and_return(@info)
    @info_tags = mock('info_tags')
    @info.stub!(:tags).and_return(@info_tags)
    @controller.instance_variable_set('@current_user', @current_user)
  end
end

describe "Routing shortcuts for Tags via account info (/account/info/) should map" do
  include TagsViaAccountInfoHelper
  controller_name :tags
  
  before(:each) do
    setup_mocks
    @tag = mock('Tag')
    @tag.stub!(:to_param).and_return('2')
    @info_tags.stub!(:find).and_return(@tag)
    
    @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:account_info_tag])
    get :show, :id => 2
  end
  
  it "resources_path to /account/info/tags" do
    controller.resources_path.should == '/account/info/tags'
  end

  it "resource_path to /account/info/tags/2" do
    controller.resource_path.should == '/account/info/tags/2'
  end
  
  it "resource_path(9) to /account/info/tags/9" do
    controller.resource_path(9).should == '/account/info/tags/9'
  end

  it "edit_resource_path to /account/info/tags/2/edit" do
    controller.edit_resource_path.should == '/account/info/tags/2/edit'
  end
  
  it "edit_resource_path(9) to /account/info/tags/9/edit" do
    controller.edit_resource_path(9).should == '/account/info/tags/9/edit'
  end
  
  it "new_resource_path to /account/info/tags/new" do
    controller.new_resource_path.should == '/account/info/tags/new'
  end
  
  it "enclosing_resource_path to /account/info" do
    controller.enclosing_resource_path.should == "/account/info"
  end
end

describe "resource_service in TagsController via Account Info" do
  include TagsViaAccountInfoHelper
  controller_name :tags
  
  before(:each) do
    @info = Info.create
    @account = User.create :info => @info
    @info.tags << (@tag = Tag.create)
    @other_tag = Tag.create
    
    @controller.instance_variable_set('@current_user', @account)
    @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:account_info_tags])
    get :index
    @resource_service = controller.send :resource_service
  end
  
  it "should build new tag with @info fk and type with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Tag)
    resource.taggable_id.should == @info.id
    resource.taggable_type.should == 'Info'
  end
  
  it "should find @tag with find(@tag.id)" do
    resource = @resource_service.find(@tag.id)
    resource.should == @tag
  end
  
  it "should raise RecordNotFound with find(@other_tag.id)" do
    lambda{ @resource_service.find(@other_tag.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only tags belonging to @info with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Tag.find(:all, :conditions => "taggable_id = #{@info.id} AND taggable_type = 'Info'")
  end
end

describe "Requesting /forums/1/tags using GET" do
  include TagsViaAccountInfoHelper
  controller_name :tags

  before(:each) do
    setup_mocks
    @tags = mock('Tags')
    @info_tags.stub!(:find).and_return(@tags)
  end
  
  def do_get
    @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:account_info_tags])
    get :index
  end

  it "should find the account as current_user" do
    do_get
    assigns['account'].should == @current_user
  end

  it "should get info from current_user" do
    @current_user.should_receive(:info).and_return(@info)
    do_get
  end

  it "should get tags assoc from info" do
    @info.should_receive(:tags).and_return(@info_tags)
    do_get
  end

  it "should get tags from tags assoc" do
    @info_tags.should_receive(:find).with(:all).and_return(@tags)
    do_get
  end
end