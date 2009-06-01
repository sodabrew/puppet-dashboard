require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module ForumPostsSpecHelper
  def setup_mocks
    @forum = mock('Forum')
    @forum_posts = mock('Assoc: forum_posts')
    @forum.stub!(:posts).and_return(@forum_posts)
    @forum.stub!(:to_param).and_return("2")
    
    Forum.stub!(:find).and_return(@forum)
  end
end

describe "Routing shortcuts for ForumPosts (forums/2/posts/1) should map" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('Post')
    @post.stub!(:to_param).and_return('1')
    @forum_posts.stub!(:find).and_return(@post)
  
    get :show, :forum_id => "2", :id => "1"
  end
  
  it "resources_path to /forums/2/posts" do
    controller.resources_path.should == '/forums/2/posts'
  end

  it "resource_path to /forums/2/posts/1" do
    controller.resource_path.should == '/forums/2/posts/1'
  end
  
  it "resource_path(9) to /forums/2/posts/9" do
    controller.resource_path(9).should == '/forums/2/posts/9'
  end

  it "edit_resource_path to /forums/2/posts/1/edit" do
    controller.edit_resource_path.should == '/forums/2/posts/1/edit'
  end
  
  it "edit_resource_path(9) to /forums/2/posts/9/edit" do
    controller.edit_resource_path(9).should == '/forums/2/posts/9/edit'
  end
  
  it "new_resource_path to /forums/2/posts/new" do
    controller.new_resource_path.should == '/forums/2/posts/new'
  end
  
  it "resource_tags_path to /forums/2/posts/1/tags" do
    controller.resource_tags_path.should == "/forums/2/posts/1/tags"
  end

  it "resource_tags_path(9) to /forums/2/posts/9/tags" do
    controller.resource_tags_path(9).should == "/forums/2/posts/9/tags" 
  end
  
  it "resource_tag_path(5) to /forums/2/posts/1/tags/5" do
    controller.resource_tag_path(5).should == "/forums/2/posts/1/tags/5"
  end
  
  it "resource_tag_path(9,5) to /forums/2/posts/9/tags/5" do
    controller.resource_tag_path(9,5).should == "/forums/2/posts/9/tags/5"
  end
  
  it "enclosing_resource_path to /forums/2" do
    controller.enclosing_resource_path.should == '/forums/2'
  end
  
  it "enclosing_resource_path(9) to /forums/9" do
    controller.enclosing_resource_path(9).should == '/forums/9'
  end
  
  it "enclosing_resources_path to /forums" do
    controller.enclosing_resources_path.should == '/forums'
  end
  
  it "new_enclosing_resource_path to /forums/new" do
    controller.new_enclosing_resource_path.should == '/forums/new'
  end
  
  it "enclosing_resource_tags_path to /forums/2/tags" do
    controller.enclosing_resource_tags_path.should == '/forums/2/tags'
  end

  it "enclosing_resource_tag_path(9) to /forums/2/tags/9" do
    controller.enclosing_resource_tag_path(9).should == '/forums/2/tags/9'
  end

  it "enclosing_resource_tag_path(8,9) to /forums/8/tags/9" do
    controller.enclosing_resource_tag_path(8,9).should == '/forums/8/tags/9'
  end
end

describe ForumPostsController, " errors" do
  controller_name :forum_posts
  
  it "should raise ResourceMismatch for /posts" do
    lambda{ get :index }.should raise_error(Ardes::ResourcesController::ResourceMismatch)
  end

  it "should raise ResourceMismatch, when route does not contain the resource segment" do
    lambda{ get :index, :foo_id => 1}.should raise_error(Ardes::ResourcesController::ResourceMismatch)
  end
  
  it "should raise NoRecognizedRoute when no route is recognized" do
    ::ActionController::Routing::Routes.stub!(:routes_for_controller_and_action).and_return([])
    lambda{ get :index }.should raise_error(Ardes::ResourcesController::NoRecognizedRoute)
  end
end

describe "resource_service in ForumPostsController" do
  controller_name :forum_posts
  
  before(:each) do
    @forum        = Forum.create
    @post         = Post.create :forum_id => @forum.id
    @other_forum  = Forum.create
    @other_post   = Post.create :forum_id => @other_forum.id
    
    get :index, :forum_id => @forum.id
    @resource_service = controller.send :resource_service
  end
  
  it "should build new post with @forum foreign key with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Post)
    resource.forum_id.should == @forum.id
  end
  
  it "should find @post with find(@post.id)" do
    resource = @resource_service.find(@post.id)
    resource.should == @post
  end
  
  it "should raise RecordNotFound with find(@other_post.id)" do
    lambda{ @resource_service.find(@other_post.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only posts belonging to @forum with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Post.find(:all, :conditions => "forum_id = #{@forum.id}")
  end
end

describe ForumPostsController, ' order of before_filters' do
  before do
    @forum        = Forum.create
    get :index, :forum_id => @forum.id
  end
  
  it { @controller.filter_trace.should == [:abstract, :posts, :load_enclosing, :forum_posts] }
end

describe "Requesting /forums/2/posts (testing the before filters)" do
  include ForumPostsSpecHelper
  controller_name :forum_posts
  
  before(:each) do
    setup_mocks
    @posts = mock('Posts')
    @forum_posts.stub!(:find).and_return(@posts)
  end
  
  def do_get
    get :index, :forum_id => '2'
  end
    
  it "should find the forum" do
    Forum.should_receive(:find).with('2').and_return(@forum)
    do_get
  end
  
  it "should assign the form as other_name_for_forum" do
    do_get
    assigns[:other_name_for_forum].should == assigns[:forum]
  end
  
  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @forum
  end
  
  it "should assign the forum_posts association as the posts resource_service" do
    @forum.should_receive(:posts).and_return(@forum_posts)
    do_get
    @controller.resource_service.should == @forum_posts
  end 
end

describe "Requesting /forums/2/posts using GET" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @posts = mock('Posts')
    @forum_posts.stub!(:find).and_return(@posts)
  end
  
  def do_get
    get :index, :forum_id => '2'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index.rhtml" do
    do_get
    response.should render_template(:index)
  end
  
  it "should find all posts, in reverse order (because of AbstractPostsController)" do
    @forum_posts.should_receive(:find).with(:all, :order => 'id DESC').and_return(@posts)
    do_get
  end
  
  it "should assign the found posts for the view" do
    do_get
    assigns[:posts].should == @posts
  end
end

describe "Requesting /forums/2/posts/1 using GET" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('a post')
    @forum_posts.stub!(:find).and_return(@post)
  end
  
  def do_get
    get :show, :id => "1", :forum_id => "2"
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
    @forum_posts.should_receive(:find).with("1").and_return(@post)
    do_get
  end
  
  it "should assign the found thing for the view" do
    do_get
    assigns[:post].should == @post
  end
end

describe "Requesting /forums/2/posts/new using GET" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('new Post')
    @forum_posts.stub!(:new).and_return(@post)
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
  
  it "should create an new thing" do
    @forum_posts.should_receive(:new).and_return(@post)
    do_get
  end
  
  it "should not save the new thing" do
    @post.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new thing for the view" do
    do_get
    assigns[:post].should == @post
  end
end

describe "Requesting /forums/2/posts/1/edit using GET" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('Post')
    @forum_posts.stub!(:find).and_return(@post)
  end
 
  def do_get
    get :edit, :id => "1", :forum_id => "2"
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
    @forum_posts.should_receive(:find).with("1").and_return(@post)
    do_get
  end
  
  it "should assign the found Thing for the view" do
    do_get
    assigns(:post).should equal(@post)
  end
end

describe "Requesting /forums/2/posts using POST" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('Post')
    @post.stub!(:save).and_return(true)
    @post.stub!(:to_param).and_return("1")
    @forum_posts.stub!(:new).and_return(@post)
  end
  
  def do_post
    post :create, :post => {:name => 'Post'}, :forum_id => "2"
  end
  
  it "should make a new post" do
    @forum_posts.should_receive(:new).with({'name' => 'Post'}).and_return(@post)
    do_post
  end

  it "should attempt to save the new post" do
    @post.should_receive(:save).and_return(true)
    do_post
  end
  
  it "should redirect to the new post.save == true" do
    do_post
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/2/posts/1"
  end
  
  it "should render new when post.save == false" do
    @post.stub!(:save).and_return(false)
    do_post
    response.should render_template(:new)
  end
end

describe "Requesting /forums/2/posts/1 using PUT" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('Post', :null_object => true)
    @post.stub!(:to_param).and_return("1")
    @forum_posts.stub!(:find).and_return(@post)
  end
  
  def do_update
    put :update, :id => "1", :forum_id => "2"
  end
  
  it "should find the post requested" do
    @forum_posts.should_receive(:find).with("1").and_return(@post)
    do_update
  end

  it "should update the found post" do
    @post.should_receive(:update_attributes)
    do_update
  end

  it "should assign the found post for the view" do
    do_update
    assigns(:post).should == @post
  end

  it "should redirect to the post" do
    do_update
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/2/posts/1"
  end
end

describe "Requesting /forums/2/posts/1 using DELETE" do
  include ForumPostsSpecHelper
  controller_name :forum_posts

  before(:each) do
    setup_mocks
    @post = mock('Post', :null_object => true)
    @forum_posts.stub!(:find).and_return(@post)
  end
  
  def do_delete
    delete :destroy, :id => "1", :forum_id => "2"
  end

  it "should find the post requested" do
    @forum_posts.should_receive(:find).with("1").and_return(@post)
    do_delete
  end
  
  it "should call destroy on the found thing" do
    @post.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the things list" do
    do_delete
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/2/posts"
  end
end