require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "ResourcesController (in general)" do
  
  before do
    @controller = Class.new(ApplicationController)
    @controller.resources_controller_for :forums
  end
  
  it "nested_in :foo, :polymorphic => true, :class => User should raise argument error (no options or block with polymorphic)" do
    lambda { @controller.nested_in :foo, :polymorphic => true, :class => User }.should raise_error(ArgumentError)
  end
  
  it "resources_controller_for :forums, :in => [:user, '*', '*', :comment] should raise argument error (no multiple wildcards in a row)" do
    lambda { @controller.resources_controller_for :forums, :in => [:user, '*', '*', :comment] }.should raise_error(ArgumentError)
  end
end

describe "ResourcesController#enclosing_resource_name" do
  before do
    @controller = TagsController.new
    info = mock_model(Info, :tags => [])
    @controller.stub!(:current_user).and_return(mock_model(User, :info => info))
    @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:account_info_tags])
    @controller.send :load_enclosing_resources
  end

  it "should be the name of the mapped enclosing_resource" do
    @controller.enclosing_resource_name.should == 'info'
  end
end

describe "A controller's resource_service" do
  before do
    @controller = ForumsController.new
  end
    
  it 'may be explicitly set with #resource_service=' do
    @controller.resource_service = 'foo'
    @controller.resource_service.should == 'foo'
  end
end

describe "deprecated methods" do
  before do 
    @controller = ForumsController.new
    @controller.resource = Forum.new
  end
  
  it "#save_resource should send resource.save" do
    ActiveSupport::Deprecation.silence do
      @controller.resource.should_receive :save
      @controller.save_resource
    end
  end
end
