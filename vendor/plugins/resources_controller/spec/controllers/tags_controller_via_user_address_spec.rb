require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module TagsViaUserAddressSpecHelper
  def setup_mocks
    @user = mock_model(User)
    User.stub!(:find_by_login).and_return(@user)
    @user.stub!(:to_param).and_return('dave')
    @user_addresses = mock('user_addresses assoc')
    @user.stub!(:addresses).and_return(@user_addresses)
    
    @address = mock_model(Address)
    @user_addresses.stub!(:find).and_return(@address)
    @address.stub!(:to_param).and_return('2')
    @address_tags = mock('address_tags assoc')
    @address.stub!(:tags).and_return(@address_tags)
  end
end

describe "Routing shortcuts for Tags via User and Address (users/dave/addresses/2/tags/3) should map" do
  include TagsViaUserAddressSpecHelper
  controller_name :tags
  
  before(:each) do
    setup_mocks
    @tag = mock_model(Tag)
    @tag.stub!(:to_param).and_return('3')
    @address_tags.stub!(:find).and_return(@tag)
    
    get :show, :user_id => "dave", :address_id => "2", :id => "3"
  end
  
  it "resources_path to /users/dave/addresses/2/tags" do
    controller.resources_path.should == '/users/dave/addresses/2/tags'
  end

  it "resource_path to /users/dave/addresses/2/tags/3" do
    controller.resource_path.should == '/users/dave/addresses/2/tags/3'
  end
  
  it "resource_path(9) to /users/dave/addresses/2/tags/9" do
    controller.resource_path(9).should == '/users/dave/addresses/2/tags/9'
  end

  it "edit_resource_path to /users/dave/addresses/2/tags/3/edit" do
    controller.edit_resource_path.should == '/users/dave/addresses/2/tags/3/edit'
  end
  
  it "edit_resource_path(9) to /users/dave/addresses/2/tags/9/edit" do
    controller.edit_resource_path(9).should == '/users/dave/addresses/2/tags/9/edit'
  end
  
  it "new_resource_path to /users/dave/addresses/2/tags/new" do
    controller.new_resource_path.should == '/users/dave/addresses/2/tags/new'
  end
  
  it "enclosing_resource_path to /users/dave/addresses/2" do
    controller.enclosing_resource_path.should == "/users/dave/addresses/2"
  end
end

describe "resource_service in TagsController via User and Address" do
  controller_name :tags
  
  before(:each) do
    @user       = User.create
    @address        = Address.create :user_id => @user.id
    @tag         = Tag.create :taggable_id => @address.id, :taggable_type => 'Address'
    @other_address  = Address.create :user_id => @user.id
    @other_tag   = Tag.create :taggable_id => @other_address.id, :taggable_type => 'Address'
    
    get :index, :user_id => @user.id, :address_id => @address.id
    @resource_service = controller.send :resource_service
  end
  
  it "should build new tag with @address fk and type with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Tag)
    resource.taggable_id.should == @address.id
    resource.taggable_type.should == 'Address'
  end
  
  it "should find @tag with find(@tag.id)" do
    resource = @resource_service.find(@tag.id)
    resource.should == @tag
  end
  
  it "should raise RecordNotFound with find(@other_tag.id)" do
    lambda{ @resource_service.find(@other_tag.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only tags belonging to @address with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Tag.find(:all, :conditions => "taggable_id = #{@address.id} AND taggable_type = 'Address'")
  end
end

describe "Requesting /users/dave/addresses/2/tags using GET" do
  include TagsViaUserAddressSpecHelper
  controller_name :tags

  before(:each) do
    setup_mocks
    @tags = mock('Tags')
    @address_tags.stub!(:find).and_return(@tags)
  end
  
  def do_get
    get :index, :user_id => "dave", :address_id => 2
  end

  it "should find the user" do
    User.should_receive(:find_by_login).with('dave').and_return(@user)
    do_get
  end
  
  it "should find the address" do
    @user_addresses.should_receive(:find).with('2').and_return(@address)
    do_get
  end

  it "should assign the found address for the view" do
    do_get
    assigns[:address].should == @address
  end

  it "should assign the address_tags association as the tags resource_service" do
    @address.should_receive(:tags).and_return(@address_tags)
    do_get
    @controller.resource_service.should == @address_tags
  end 
end