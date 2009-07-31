require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuditsController, 'when integrating' do
  integrate_views

  before :each do
    @audit = Audit.generate!
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
      get :show, :id => @audit.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @audit.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @audit = Audit.spawn
    end
    
    def do_request
      post :create, :audit => @audit.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @audit.id.to_s, :audit => @audit.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @audit.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe AuditsController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
