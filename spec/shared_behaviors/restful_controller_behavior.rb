shared_examples_for 'a RESTful controller with an index action' do
  before :each do
    path_name_setup
  end

  describe "handling GET /plural (index)" do
    before(:each) do
      @object = stub(@model_name)
      @objects = [@object]
      @model_class.stubs(:find).returns(@objects)
      do_login if needs_login?

      find_target_setup :plural
    end

    def do_get
      get :index, {}.merge(nesting_params)
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end

    if has_parent?
      it 'should find the parent object' do
        @parent_class.expects(:find).with(parent_id).returns(@parent)
        do_get
      end
    end

    it "should find the objects" do
      @find_target.expects(:find).returns(@objects)
      do_get
    end

    it "should make the found objects available to the view" do
      do_get
      assigns[@model_plural.to_sym].should == @objects
    end

    if has_parent?
      it 'should make the parent object available to the view' do
        do_get
        assigns[@parent_name.to_sym].should == @parent
      end
    end
  end
end

shared_examples_for 'a RESTful controller with a show action' do
  before :each do
    path_name_setup
  end

  describe "handling GET /plural/1 (show)" do
    before(:each) do
      @obj_id = '1'
      @obj = stub(@model_name)
      @model_class.stubs(:find).returns(@obj)
      do_login if needs_login?

      find_target_setup
    end

    def do_get
      get :show, { :id => @obj_id }.merge(nesting_params)
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render the show template" do
      do_get
      response.should render_template('show')
    end

    if has_parent?
      it 'should find the parent object' do
        @parent_class.expects(:find).with(parent_id).returns(@parent)
        do_get
      end
    end

    it "should find the object requested" do
      @find_target.expects(:find).with(@obj_id, anything).returns(@obj)
      do_get
    end

    it "should make the found object available to the view" do
      do_get
      assigns[@model_singular.to_sym].should equal(@obj)
    end

    if has_parent?
      it 'should make the parent object available to the view' do
        do_get
        assigns[@parent_name.to_sym].should == @parent
      end
    end
  end
end

shared_examples_for 'a RESTful controller with a new action' do
  before :each do
    path_name_setup
  end

  describe "handling GET /plural/new" do
    before(:each) do
      @obj = stub(@model_name)
      @model_class.stubs(:find).returns(@obj)
      @model_class.stubs(:new).returns(@obj)
      do_login if needs_login?
    end

    def do_get
      get :new, {}.merge(nesting_params)
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render the new template" do
      do_get
      response.should render_template('new')
    end

    it "should create a new object" do
      @model_class.expects(:new).returns(@obj)
      do_get
    end

    it "should not save the new object" do
      @obj.expects(:save).never
      do_get
    end

    it "should make the new object available to the view" do
      do_get
      assigns[@model_singular.to_sym].should equal(@obj)
    end
  end
end

shared_examples_for 'a RESTful controller with a create action' do
  before :each do
    path_name_setup
  end

  describe "handling POST /plural (create)" do
    before(:each) do
      @obj = @model_class.new
      @obj_id = 1
      @obj.stubs(:id).returns(@obj_id)
      @model_class.stubs(:new).returns(@obj)
      do_login if needs_login?

      object_path_setup
    end

    def post_with_successful_save
      @obj.expects(:save).returns(true)
      post :create, { @model_singular.to_sym => {} }.merge(nesting_params)
    end

    def post_with_failed_save
      @obj.expects(:save).returns(false)
      post :create, { @model_singular.to_sym => {} }.merge(nesting_params)
    end

    it "should create a new object" do
      @model_class.expects(:new).with({}).returns(@obj)
      post_with_successful_save
    end

    it "should redirect to the new object on a successful save" do
      post_with_successful_save
      response.should redirect_to(self.send("#{@object_path_method}_url".to_sym, *@url_args))
    end

    it "should re-render 'new' on a failed save" do
      post_with_failed_save
      response.should render_template('new')
    end
  end
end

shared_examples_for 'a RESTful controller with an edit action' do
  before :each do
    path_name_setup
  end

  describe "handling GET /plural/1/edit (edit)" do
    before(:each) do
      @obj = stub(@model_name)
      @model_class.stubs(:find).returns(@obj)
      do_login if needs_login?
    end

    def do_get
      get :edit, { :id => "1" }.merge(nesting_params)
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render the edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should find the object requested" do
      @model_class.expects(:find).returns(@obj)
      do_get
    end

    it "should make the found object available to the view" do
      do_get
      assigns[@model_singular.to_sym].should equal(@obj)
    end
  end
end

shared_examples_for 'a RESTful controller with an update action' do
  before :each do
    path_name_setup
  end

  describe "handling PUT /plural/1 (update)" do
    before(:each) do
      @obj_id = '1'
      @obj = stub(@model_name, :to_s => @obj_id)
      @model_class.stubs(:find).returns(@obj)
      do_login if needs_login?

      object_path_setup
      find_target_setup
    end

    def put_with_successful_update
      @obj.expects(:update_attributes).returns(true)
      put :update, { :id => @obj_id }.merge(nesting_params)
    end

    def put_with_failed_update
      @obj.expects(:update_attributes).returns(false)
      put :update, { :id => @obj_id }.merge(nesting_params)
    end

    if has_parent?
      it 'should find the parent object' do
        @parent_class.expects(:find).with(parent_id).returns(@parent)
        do_get
      end
    end

    it "should find the object requested" do
      @find_target.expects(:find).with(@obj_id).returns(@obj)
      put_with_successful_update
    end

    it "should update the found object" do
      put_with_successful_update
      assigns(@model_singular.to_sym).should equal(@obj)
    end

    it "should make the found object available to the view" do
      put_with_successful_update
      assigns(@model_singular.to_sym).should equal(@obj)
    end

    if has_parent?
      it 'should make the parent object available to the view' do
        do_get
        assigns[@parent_name.to_sym].should == @parent
      end
    end

    it "should redirect to the object on a successful update" do
      put_with_successful_update
      response.should redirect_to(self.send("#{@object_path_method}_url".to_sym, *@url_args))
    end

    it "should re-render 'edit' on a failed update" do
      put_with_failed_update
      response.should render_template('edit')
    end
  end
end

shared_examples_for 'a RESTful controller with a destroy action' do
  before :each do
    path_name_setup
  end

  describe "handling DELETE /plural/1 (destroy)" do
    before(:each) do
      @obj_id = '1'
      @obj = stub(@model_name, :destroy => true)
      @model_class.stubs(:find).returns(@obj)
      do_login if needs_login?

      object_path_setup :plural
      find_target_setup
    end

    def do_delete
      delete :destroy, { :id => @obj_id }.merge(nesting_params)
    end

    if has_parent?
      it 'should find the parent object' do
        @parent_class.expects(:find).with(parent_id).returns(@parent)
        do_get
      end
    end

    it "should find the object requested" do
      @find_target.expects(:find).with(@obj_id).returns(@obj)
      do_delete
    end

    it "should call destroy on the found object" do
      @obj.expects(:destroy).returns(true)
      do_delete
    end

    it "should redirect to the object list" do
      do_delete
      response.should redirect_to(self.send("#{@object_path_method}_url".to_sym, *@url_args))
    end
  end
end


shared_examples_for 'a RESTful controller' do

  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with a create action'
  it_should_behave_like 'a RESTful controller with an edit action'
  it_should_behave_like 'a RESTful controller with an update action'
  it_should_behave_like 'a RESTful controller with a destroy action'

end

shared_examples_for 'a controller with login restrictions' do
  describe "when user is not logged in" do
    before :each do
      controller.stubs(:authorized?).returns(false)
    end

    it 'GET /plural (index) should not be accessible' do
      get :index
      response.should redirect_to(new_wants_you_to_url)
    end

    it 'GET /plural/1 (show) should not be accessible' do
      get :show, :id => "1"
      response.should redirect_to(new_wants_you_to_url)
    end

    it 'GET /plural/new should not be accessible' do
      get :new
      response.should redirect_to(new_wants_you_to_url)
    end

    it 'GET /plural/1/edit (edit) should not be accessible' do
      get :edit, :id => 1
      response.should redirect_to(new_wants_you_to_url)
    end

    it 'POST /plural (create) should not be accessible' do
      post :create, {}
      response.should redirect_to(new_wants_you_to_url)
    end

    it 'PUT /plural/1 (update) should not be accessible' do
      put :update, :id => '1'
      response.should redirect_to(new_wants_you_to_url)
    end

    it 'DELETE /plural/1 (destroy) should not be accessible' do
      delete :destroy, :id => '1'
      response.should redirect_to(new_wants_you_to_url)
    end

    describe "request saving" do
      before :each do
        request.stubs(:request_uri).returns('fake_address')
      end

      it 'GET /plural (index) should save the requested URL' do
        get :index
        session[:return_to].should == 'fake_address'
      end

      it 'GET /plural/1 (show) should save the requested URL' do
        get :show, :id => "1"
        session[:return_to].should == 'fake_address'
      end

      it 'GET /plural/new should save the requested URL' do
        get :new
        session[:return_to].should == 'fake_address'
      end

      it 'GET /plural/1/edit (edit) should save the requested URL' do
        get :edit, :id => 1
        session[:return_to].should == 'fake_address'
      end

      it 'POST /plural (create)  should save the requested URL' do
        post :create, {}
        session[:return_to].should == 'fake_address'
      end

      it 'PUT /plural/1 (update) should save the requested URL' do
        put :update, :id => '1'
        session[:return_to].should == 'fake_address'
      end

      it 'DELETE /plural/1 (destroy) should save the requested URL' do
        delete :destroy, :id => '1'
        session[:return_to].should == 'fake_address'
      end
    end
  end
end


shared_examples_for 'a RESTful controller requiring login' do
  def do_login
    login_as Login.find(:first)
  end

  def needs_login?
    true
  end

  it_should_behave_like 'a RESTful controller'
  it_should_behave_like 'a controller with login restrictions'
end


#### helper methods for various setup or behavior needs

# declare a default predicate for whether we need to bother with login overhead for these examples
def needs_login?() false end

unless defined? nesting_params
  def nesting_params
    {}
  end
end

def has_parent?
  parent_key
end

def parent_key
  nesting_params.keys.detect { |k|  k.to_s.ends_with?('_id') }
end

def parent_id
  nesting_params[parent_key]
end

def parent_type
  parent_key.to_s.sub(/_id$/, '')
end

def path_name_setup
  @name           ||= controller.class.name                         # => 'FoosController'
  @plural_path    ||= @name.sub('Controller', '').tableize          # => 'foos'
  @singular_path  ||= @plural_path.singularize                      # => 'foo'
  @model_name     ||= @name.to_s.sub('Controller', '').singularize  # => 'Foo'
  @model_plural   ||= @plural_path                                  # => 'foos'
  @model_singular ||= @singular_path                                # => 'foo'
  @model_class    ||= @model_name.constantize                       # => Foo

  if has_parent?
    @parent_name  = parent_type.camelize
    @parent_class = @parent_name.constantize
  end
end

def find_target_setup(arity = :singular)
  find_return = case arity
    when :plural
      @objects
    when :singular
      @obj
    else
      raise "Don't know what to make parent association return"
  end

  @find_target = @model_class
  if has_parent?
    @parent_association = stub("#{@parent_name} #{@model_plural}", :find => find_return)
    @parent = stub(@parent_name, @model_plural.to_sym => @parent_association, :to_param => parent_id)
    @parent_class.stubs(:find).returns(@parent)
    @find_target = @parent_association
  end
end

def object_path_setup(arity = :singular)
  @url_args = []
  @url_args.push(@obj_id) unless arity == :plural
  @url_args.compact!
  @object_path_method = instance_variable_get("@#{arity}_path")
  if has_parent?
    @object_path_method = "#{parent_type}_#{@object_path_method}"
    @url_args.unshift(parent_id)
  end
end
#### end of helper methods

__END__

# we're not yet using this, and it's, therefore, not been exercised properly, so disabling this for now

shared_examples_for 'a RESTful controller with XML support' do

  before :each do
#    @controller_name     ||= controller_name                                             # => 'FoosController'
    @plural_path         ||= @controller_name.sub('Controller', '').tableize             # => 'foos'
    @singular_path       ||= @plural_path.singularize                                    # => 'foo'
    @model_name          ||= @controller_name.to_s.sub('Controller', '').singularize     # => 'Foo'
    @model_plural        ||= @plural_path                                                # => 'foos'
    @model_singular      ||= @singular_path                                              # => 'foo'
    @model_class         ||= @model_name.constantize                                     # => Foo
  end

  describe "handling GET /plural.xml (index)" do
    before(:each) do
      @obj = stub(@model_name, :to_xml => "XML")
      @model_class.stubs(:find).returns(@obj)
      do_login if needs_login?
    end

    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all the objects" do
      @model_class.expects(:find).with(:all).returns(@obj)
      do_get
    end

    it "should render the found objects as xml" do
      @obj.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /plural/1.xml (show)" do
    before(:each) do
      @obj = stub(@model_name, :to_xml => "XML")
      @model_class.stubs(:find).returns(@obj)
      do_login if needs_login?
    end

    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find the object requested" do
      @model_class.expects(:find).with("1").returns(@obj)
      do_get
    end

    it "should render the found object as xml" do
      @obj.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end
end

shared_examples_for 'a RESTful controller with XML support requiring login' do
  def do_login
    login_as Login.find(:first)
  end

  def needs_login?
    true
  end

  it_should_behave_like 'a RESTful controller with XML support'
end
