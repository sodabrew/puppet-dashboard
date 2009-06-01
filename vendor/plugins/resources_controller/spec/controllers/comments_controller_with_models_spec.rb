require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe CommentsController, "without stubs" do
  before do
    @user = User.create!
    @forum = Forum.create!
    @post = Post.create! :forum => @forum
    @comment = Comment.create! :user => @user, :post => @post
  end
  
  describe "responding to GET index" do
    def do_get
      get :index, :forum_id => @forum.id, :post_id => @post.id
    end
    
    it "should expose all comments as @comments" do
      do_get
      assigns[:comments].should == [@comment]
    end

    describe "with mime type of xml" do
      it "should render all comments as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        do_get
        response.body.should == [@comment].to_xml
      end
    end
  end

  describe "responding to GET show" do
    def do_get
      get :show, :id => @comment.id, :forum_id => @forum.id, :post_id => @post.id
    end
    
    it "should expose the requested comment as @comment" do
      do_get
      assigns[:comment].should == @comment
    end
    
    describe "with mime type of xml" do
      it "should render the requested comment as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        do_get
        response.body.should == @comment.to_xml
      end
    end
  end

  describe "responding to GET new" do
    def do_get
      get :new, :forum_id => @forum.id, :post_id => @post.id
    end
  
    it "should expose a new comment as @comment" do
      do_get
      assigns[:comment].should be_new_record
      assigns[:comment].post.should == @post
    end
  end

  describe "responding to GET edit" do
    def do_get
      get :edit, :id => @comment.id, :forum_id => @forum.id, :post_id => @post.id
    end
    
    it "should expose the requested comment as @comment" do
      do_get
      assigns[:comment].should == @comment
    end
  end

  describe "responding to POST create" do
    describe "with valid params" do
      def do_post
        post :create, :forum_id => @forum.id, :post_id => @post.id, :comment => {:user_id => @user.id}
      end
      
      it "should create a comment" do
        lambda { do_post }.should change(Comment, :count).by(1)
      end
      
      it "should expose the newly created comment as @comment" do
        do_post
        assigns(:comment).should == Comment.find(:first, :order => 'id DESC')
      end

      it "should be resource_saved?" do
        do_post
        @controller.should be_resource_saved
      end
      
      it "should redirect to the created comment" do
        do_post
        response.should redirect_to(forum_post_comment_url(@forum, @post, Comment.find(:first, :order => 'id DESC')))
      end
    end
    
    describe "with invalid params" do
      def do_post
        post :create, :forum_id => @forum.id, :post_id => @post.id, :comment => {:user_id => ''}
      end

      it "should not create a comment" do
        lambda { do_post }.should_not change(Comment, :count)
      end
 
      it "should expose a newly created but unsaved comment as @comment" do
        do_post
        assigns(:comment).should be_new_record
        assigns(:comment).post.should == @post
      end

      it "should not be resource_saved?" do
        do_post
        @controller.should_not be_resource_saved
      end

      it "should re-render the 'new' template" do
        do_post
        response.should render_template('new')
      end
    end
  end

  describe "responding to PUT udpate" do
    describe "with valid params" do
      before do
        @new_user = User.create!
      end
      
      def do_put
        put :update, :id => @comment.id, :forum_id => @forum.id, :post_id => @post.id, :comment => {:user_id => @new_user.id}
      end

      it "should update the requested comment" do
        do_put
        Comment.find(@comment.id).user_id.should == @new_user.id
      end

      it "should not contain errors on comment" do
        do_put
        @comment.errors.should be_empty
      end
      
      it "should be resource_saved?" do
        do_put
        @controller.should be_resource_saved
      end
      
      it "should expose the requested comment as @comment" do
        do_put
        assigns[:comment].should == @comment
      end

      it "should redirect to the comment" do
        do_put
        response.should redirect_to(forum_post_comment_url(@forum, @post, @comment))
      end
    end
    
    describe "with invalid params" do
      def do_put
        put :update, :id => @comment.id, :forum_id => @forum.id, :post_id => @post.id, :comment => {:user_id => ''}
      end

      it "should fail to update the requested comment" do
        do_put
        Comment.find(@comment.id).user_id.should == @user.id 
      end

      it "should not be resource_saved?" do
        do_put
        @controller.should_not be_resource_saved
      end
      
      it "should expose the requested comment as @comment" do
        do_put
        assigns[:comment].should == @comment
      end

      it "should re-render the 'edit' template" do
        do_put
        response.should render_template('edit')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_delete
      delete :destroy, :id => @comment.id, :forum_id => @forum.id, :post_id => @post.id
    end
    
    it "should delete the requested comment" do
      lambda { do_delete }.should change(Comment, :count).by(-1)
    end

    it "should redirect to the comments list" do
      do_delete
      response.should redirect_to(forum_post_comments_url(@forum, @post))
    end
  end
end
