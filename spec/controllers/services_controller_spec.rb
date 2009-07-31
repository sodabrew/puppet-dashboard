require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ServicesController, 'when integrating' do
  integrate_views

  before :each do
    @service = Service.generate!
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
      get :show, :id => @service.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @service.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    def do_request
      post :create, :service => @service.attributes
    end

    it_should_behave_like "a successful action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @service.id.to_s, :service => @service.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @service.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe ServicesController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
