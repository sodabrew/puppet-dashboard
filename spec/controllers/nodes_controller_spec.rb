require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodesController, 'when integrating' do
  integrate_views

  before :each do
    @node = Node.generate!
  end

  describe 'index' do
    def do_request
      get :index
    end

    it_should_behave_like "a successful action"
  end

  describe 'new' do
    def do_request
      get :new
    end

    it_should_behave_like "a successful action"
  end

  describe 'show' do
    def do_request
      get :show, :id => @node.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @node.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @node = Node.spawn
    end

    def do_request
      post :create, :node => @node.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @node.id.to_s, :node => @node.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @node.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe NodesController, 'when not integrating' do  
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with a create action'
  it_should_behave_like 'a RESTful controller with an update action'
  it_should_behave_like 'a RESTful controller with a destroy action'
  it_should_behave_like 'a RESTful controller with an edit action'
  
  describe '#show' do
    
  end
  
  describe '#show, when YAML is requested' do
    before :each do
      @parameters = { 'a' => 'b', 'c' => 'd' }
      @node = Node.generate!(:parameters => @parameters)
      @services = Array.new(3) { Service.generate! }
      @node.services << @services
    end
    
    def do_get  
      @request.env["HTTP_ACCEPT"] = "application/x-yaml" 
      get :show, :id => @node.id.to_s
    end
    
    it 'should return a YAML result' do
      do_get
      response.headers['Content-Type'].should match(/^application\/x-yaml/)
    end
    
    it 'should not use a layout' do
      do_get
      response.layout.should be_nil
    end

    it 'should return the node configuration as the YAML result' do
      do_get
      response.body.should == @node.configuration.to_yaml
    end
  end
end
