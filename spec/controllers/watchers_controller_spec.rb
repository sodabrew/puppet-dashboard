require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WatchersController, 'when integrating' do
  integrate_views

  before :each do
    @watcher = Watcher.generate!
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
      get :show, :id => @watcher.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @watcher.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @watcher = Watcher.spawn
    end
    
    def do_request
      post :create, :watcher => @watcher.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @watcher.id.to_s, :watcher => @watcher.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @watcher.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe WatchersController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
