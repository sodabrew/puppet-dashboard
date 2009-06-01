require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module TagsViaForumSpecHelper
  def setup_mocks
    @forum = mock('Forum')
    @forum_tags = mock('forum_tags assoc')
    Forum.stub!(:find).and_return(@forum)
    @forum.stub!(:tags).and_return(@forum_tags)
    @forum.stub!(:to_param).and_return('1')
  end
end

describe "Routing shortcuts for Tags via Forum (forums/1/tags/2) should map" do
  include TagsViaForumSpecHelper
  controller_name :tags
  
  before(:each) do
    setup_mocks
    @tag = mock('Tag')
    @tag.stub!(:to_param).and_return('2')
    @forum_tags.stub!(:find).and_return(@tag)
    
    get :show, :forum_id => "1", :id => "2"
  end
  
  it "resources_path to /forums/1/tags" do
    controller.resources_path.should == '/forums/1/tags'
  end

  it "resource_path to /forums/1/tags/2" do
    controller.resource_path.should == '/forums/1/tags/2'
  end
  
  it "resource_path(9) to /forums/1/tags/9" do
    controller.resource_path(9).should == '/forums/1/tags/9'
  end

  it "edit_resource_path to /forums/1/tags/2/edit" do
    controller.edit_resource_path.should == '/forums/1/tags/2/edit'
  end
  
  it "edit_resource_path(9) to /forums/1/tags/9/edit" do
    controller.edit_resource_path(9).should == '/forums/1/tags/9/edit'
  end
  
  it "new_resource_path to /forums/1/tags/new" do
    controller.new_resource_path.should == '/forums/1/tags/new'
  end
  
  it "enclosing_resource_path to /forums/1" do
    controller.enclosing_resource_path.should == "/forums/1"
  end
end

describe "resource_service in TagsController via Forum" do
  controller_name :tags
  
  before(:each) do
    @forum       = Forum.create
    @tag         = Tag.create :taggable_id => @forum.id, :taggable_type => 'Forum'
    @other_forum = Forum.create
    @other_tag   = Tag.create :taggable_id => @other_forum.id, :taggable_type => 'Forum'
    
    get :new, :forum_id => @forum.id
    @resource_service = controller.send :resource_service
  end
  
  it "should build new tag with @forum fk and type with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Tag)
    resource.taggable_id.should == @forum.id
    resource.taggable_type.should == 'Forum'
  end
  
  it "should find @tag with find(@tag.id)" do
    resource = @resource_service.find(@tag.id)
    resource.should == @tag
  end
  
  it "should raise RecordNotFound with find(@other_tag.id)" do
    lambda{ @resource_service.find(@other_tag.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only tags belonging to @forum with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Tag.find(:all, :conditions => "taggable_id = #{@forum.id} AND taggable_type = 'Forum'")
  end
end

describe "Requesting /forums/1/tags using GET" do
  include TagsViaForumSpecHelper
  controller_name :tags

  before(:each) do
    setup_mocks
    @tags = mock('Tags')
    @forum_tags.stub!(:find).and_return(@tags)
  end
  
  def do_get
    get :index, :forum_id => 1
  end

  it "should find the forum" do
    Forum.should_receive(:find).with('1').and_return(@forum)
    do_get
  end

  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @forum
  end

  it "should assign the forum_tags association as the tags resource_service" do
    @forum.should_receive(:tags).and_return(@forum_tags)
    do_get
    @controller.resource_service.should == @forum_tags
  end 
end

describe "Requesting /forums/1/tags/new using GET" do
  include TagsViaForumSpecHelper
  controller_name :tags

  before(:each) do
    setup_mocks
    @tag = mock('Tag')
    @forum_tags.stub!(:new).and_return(@tag)
  end
  
  def do_get
    get :new, :forum_id => 1, :tag => {"name" => "hello"}
  end

  it "should find the forum" do
    Forum.should_receive(:find).with('1').and_return(@forum)
    do_get
  end

  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @forum
  end

  it "should assign the forum_tags association as the tags resource_service" do
    @forum.should_receive(:tags).and_return(@forum_tags)
    do_get
    @controller.resource_service.should == @forum_tags
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  it "should create a new tag with params" do
    @forum_tags.should_receive(:new).with("name" => "hello").and_return(@tag)
    do_get
  end
  
  it "should not save the new category" do
    @tag.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new tag for the view" do
    do_get
    assigns[:tag].should equal(@tag)
  end
  
  it "should send :resource= to controller with @tag" do
    controller.should_receive(:resource=).with(@tag)
    do_get
  end
end