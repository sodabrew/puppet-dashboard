require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "Routing shortcuts for Tags should map" do
  controller_name :tags
  
  before(:each) do
    @tag = mock('Tag')
    @tag.stub!(:to_param).and_return('2')
    Tag.stub!(:find).and_return(@tag)
    
    @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:tag])
    get :show, :id => "2"
  end
  
  it "resources_path to /tags" do
    controller.resources_path.should == '/tags'
  end

  it "resource_path to /tags/2" do
    controller.resource_path.should == '/tags/2'
  end
  
  it "resource_path(9) to /tags/9" do
    controller.resource_path(9).should == '/tags/9'
  end

  it "edit_resource_path to /tags/2/edit" do
    controller.edit_resource_path.should == '/tags/2/edit'
  end
  
  it "edit_resource_path(9) to /tags/9/edit" do
    controller.edit_resource_path(9).should == '/tags/9/edit'
  end
  
  it "new_resource_path to /forums/1/tags/new" do
    controller.new_resource_path.should == '/tags/new'
  end
  
  it "enclosing_resource_path should raise error" do
    lambda{ controller.enclosing_resource_path }.should raise_error
  end
end

describe "resource_service in TagsController" do
  controller_name :tags
  
  before(:each) do
    @resource_service = controller.send :resource_service
  end
  
  it ".new should call new on Tag" do
    Tag.should_receive(:new).with(:args => "args")
    resource = @resource_service.new(:args => "args")
  end
  
  it ".find should call find on Tag" do
    Tag.should_receive(:find).with(:id)
    resource = @resource_service.find(:id)
  end
end

describe "Requesting /tags using GET" do
  controller_name :tags

  before(:each) do
    @tags = mock('Tags')
    Tag.stub!(:find).and_return(@tags)
  end
  
  def do_get
    @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:tags])
    get :index
  end

  it "should find the tags" do
    Tag.should_receive(:find).with(:all).and_return(@tags)
    do_get
  end

  it "should assign the tags for the view" do
    do_get
    assigns[:tags].should == @tags
  end
end