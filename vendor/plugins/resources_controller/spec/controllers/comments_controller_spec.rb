require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

module CommentsSpecHelper
  def setup_mocks
    @forum = mock('Forum')
    @forum_posts = mock('Assoc: forum_posts')
    @forum.stub!(:posts).and_return(@forum_posts)
    @forum.stub!(:to_param).and_return("3")
    
    @post = mock('Post')
    @post_comments = mock('Assoc: post_comments')
    @post.stub!(:comments).and_return(@post_comments)
    @post.stub!(:to_param).and_return("2")
        
    Forum.stub!(:find).and_return(@forum)
    @forum_posts.stub!(:find).and_return(@post)
  end
end

describe "Routing shortcuts for Comments (forums/3/posts/2/comments/1) should map" do
  include CommentsSpecHelper
  controller_name :comments
  
  before(:each) do
    setup_mocks
    @comment = mock('Comment')
    @comment.stub!(:to_param).and_return("1")
    @post_comments.stub!(:find).and_return(@comment)
    get :show, :forum_id => "3", :post_id => "2", :id => "1"
  end
  
  it "resources_path to /forums/3/posts/2/comments" do
    controller.resources_path.should == '/forums/3/posts/2/comments'
  end

  it "resource_path to /forums/3/posts/2/comments/1" do
    controller.resource_path.should == '/forums/3/posts/2/comments/1'
  end
  
  it "resource_path(9) to /forums/3/posts/2/comments/9" do
    controller.resource_path(9).should == '/forums/3/posts/2/comments/9'
  end

  it "edit_resource_path to /forums/3/posts/2/comments/1/edit" do
    controller.edit_resource_path.should == '/forums/3/posts/2/comments/1/edit'
  end
  
  it "edit_resource_path(9) to /forums/3/posts/2/comments/9/edit" do
    controller.edit_resource_path(9).should == '/forums/3/posts/2/comments/9/edit'
  end
  
  it "new_resource_path to /forums/3/posts/2/comments/new" do
    controller.new_resource_path.should == '/forums/3/posts/2/comments/new'
  end
  
  it "resource_tags_path to /forums/3/posts/2/comments/1/tags" do
    controller.resource_tags_path.should == "/forums/3/posts/2/comments/1/tags"
  end

  it "resource_tags_path(9) to /forums/3/posts/2/comments/9/tags" do
    controller.resource_tags_path(9).should == "/forums/3/posts/2/comments/9/tags" 
  end
  
  it "resource_tag_path(5) to /forums/3/posts/2/comments/1/tags/5" do
    controller.resource_tag_path(5).should == "/forums/3/posts/2/comments/1/tags/5"
  end
  
  it "resource_tag_path(9,5) to /forums/3/posts/2/comments/9/tags/5" do
    controller.resource_tag_path(9,5).should == "/forums/3/posts/2/comments/9/tags/5"
  end
end

describe "resource_service in CommentsController" do
  controller_name :comments
  
  before(:each) do
    @forum          = Forum.create
    @post           = Post.create :forum_id => @forum.id
    @comment        = Comment.create :post_id => @post.id, :user => User.create
    @other_post     = Post.create :forum_id => @forum.id
    @other_comment  = Comment.create :post_id => @other_post.id
    
    get :index, :forum_id => @forum.id, :post_id => @post.id
    @resource_service = controller.send :resource_service
  end
  
  it "should build new comment with @post foreign key with new" do
    resource = @resource_service.new
    resource.should be_kind_of(Comment)
    resource.post_id.should == @post.id
  end
  
  it "should find @comment with find(@comment.id)" do
    resource = @resource_service.find(@comment.id)
    resource.should == @comment
  end
  
  it "should raise RecordNotFound with find(@other_post.id)" do
    lambda{ @resource_service.find(@other_comment.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should find only comments belonging to @post with find(:all)" do
    resources = @resource_service.find(:all)
    resources.should be == Comment.find(:all, :conditions => "post_id = #{@post.id}")
  end
end

describe "Requesting /forums/3/posts/2/comments (testing the before filters)" do
  include CommentsSpecHelper
  controller_name :comments
  
  before(:each) do
    setup_mocks
    @comments = mock('Comments')
    @post_comments.stub!(:find).and_return(@comments)
  end
  
  def do_get
    get :index, :forum_id => '3', :post_id => '2'
  end
    
  it "should find the forum" do
    Forum.should_receive(:find).with('3').and_return(@forum)
    do_get
  end
  
  it "should assign the found forum for the view" do
    do_get
    assigns[:forum].should == @forum
  end
  
  it "should find the post" do
    @forum.should_receive(:posts).and_return(@forum_posts)
    @forum_posts.should_receive(:find).with('2').and_return(@post)
    do_get
  end
  
  it "should assign the found post for the view" do
    do_get
    assigns[:post].should == @post
  end
  
  it "should assign the post_comments association as the comments resource_service" do
    @post.should_receive(:comments).and_return(@post_comments)
    do_get
    @controller.resource_service.should == @post_comments
  end
end

describe "Requesting /forums/3/posts/2/comments using GET" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comments = mock('Comments')
    @post_comments.stub!(:find).and_return(@comments)
  end
  
  def do_get
    get :index, :forum_id => '3', :post_id => '2'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index.rhtml" do
    do_get
    response.should render_template(:index)
  end
  
  it "should find comments in post" do
    @post_comments.should_receive(:find).with(:all).and_return(@comments)
    do_get
  end
  
  it "should assign the found comments for the view" do
    do_get
    assigns[:comments].should == @comments
  end
end

describe "Requesting /forums/3/posts/3/comments/1 using GET" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comment = mock('a post')
    @post_comments.stub!(:find).and_return(@comment)
  end
  
  def do_get
    get :show, :id => "1", :forum_id => '3', :post_id => '2'
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show.rhtml" do
    do_get
    response.should render_template(:show)
  end
  
  it "should find the comment requested" do
    @post_comments.should_receive(:find).with("1").and_return(@comment)
    do_get
  end
  
  it "should assign the found comment for the view" do
    do_get
    assigns[:comment].should == @comment
  end
end

describe "Requesting /forums/3/posts/3/comments/new using GET" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comment = mock('new Comment')
    @post_comments.stub!(:new).and_return(@comment)
  end
  
  def do_get
    get :new, :forum_id => '3', :post_id => '2'
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new.rhtml" do
    do_get
    response.should render_template(:new)
  end
  
  it "should create a new comment" do
    @post_comments.should_receive(:new).and_return(@comment)
    do_get
  end
  
  it "should not save the new comment" do
    @comment.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new comment for the view" do
    do_get
    assigns[:post].should == @post
  end
end

describe "Requesting /forums/3/posts/3/comments/1/edit using GET" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comment = mock('Comment')
    @post_comments.stub!(:find).and_return(@comment)
  end
 
  def do_get
    get :edit, :id => "1", :forum_id => '3', :post_id => '2'
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit.rhtml" do
    do_get
    response.should render_template(:edit)
  end
  
  it "should find the comment requested" do
    @post_comments.should_receive(:find).with("1").and_return(@comment)
    do_get
  end
  
  it "should assign the found comment for the view" do
    do_get
    assigns(:comment).should == @comment
  end
end

describe "Requesting /forums/3/posts/3/comments using POST" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comment = mock('Comment')
    @comment.stub!(:save).and_return(true)
    @comment.stub!(:to_param).and_return("1")
    @post_comments.stub!(:new).and_return(@comment)
  end
  
  def do_post
    post :create, :comment => {:name => 'Comment'}, :forum_id => '3', :post_id => '2'
  end
  
  it "should create a new comment" do
    @post_comments.should_receive(:new).with({'name' => 'Comment'}).and_return(@comment)
    do_post
  end

  it "should redirect to the new comment" do
    do_post
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/3/posts/2/comments/1"
  end
end

describe "Requesting /forums/3/posts/3/comments/1 using PUT" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comment = mock('Comment', :null_object => true)
    @comment.stub!(:to_param).and_return("1")
    @post_comments.stub!(:find).and_return(@comment)
  end
  
  def do_update
    put :update, :id => "1", :forum_id => '3', :post_id => '2'
  end
  
  it "should find the comment requested" do
    @post_comments.should_receive(:find).with("1").and_return(@comment)
    do_update
  end

  it "should update the found comment" do
    @comment.should_receive(:update_attributes).and_return(true)
    do_update
  end

  it "should assign the found comment for the view" do
    do_update
    assigns(:comment).should == @comment
  end

  it "should redirect to the comment" do
    do_update
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/3/posts/2/comments/1"
  end
end

describe "Requesting /forums/3/posts/3/comments/1 using DELETE" do
  include CommentsSpecHelper
  controller_name :comments

  before(:each) do
    setup_mocks
    @comment = mock('Comment', :null_object => true)
    @post_comments.stub!(:find).and_return(@comment)
  end
  
  def do_delete
    delete :destroy, :id => "1", :forum_id => '3', :post_id => '2'
  end

  it "should find the comment requested" do
    @post_comments.should_receive(:find).with("1").and_return(@comment)
    do_delete
  end
  
  it "should call destroy on the found comment" do
    @comment.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the comments list" do
    do_delete
    response.should be_redirect
    response.redirect_url.should == "http://test.host/forums/3/posts/2/comments"
  end
end