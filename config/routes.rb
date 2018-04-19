PuppetDashboard::Application.routes.draw do

  root :to => 'pages#home'

  # Nodes, Groups, and Classes may all have names or numeric ids
  constraints(:id => /[^\/]+/) do
    resources :node_classes do
      collection do
        get :search
      end
    end

    resources :node_groups do
      member do
        get :diff
      end
      collection do
        get :search
      end
    end

    resources :nodes do
      member do
        patch :hide
        patch :unhide
        get :facts
        get :reports
      end
      collection do
        get :unreported
        get :failed
        get :pending
        get :unresponsive
        get :changed
        get :unchanged
        get :hidden
        get :search
      end
    end
  end

  resources :node_class_memberships do
    collection do
      get :search
    end
  end

  resources :node_group_class_memberships do
    collection do
      get :search
    end
  end

  resources :reports do
    collection do
      get :search
    end
  end

  resources :node_group_memberships, :as => :memberships

  match 'files/:action/:file1/:file2' => 'files#:action', :via => :get
  match 'files/:action/:file'         => 'files#:action', :via => :get

  match '/header.:format' => 'pages#header', :via => :get
  match 'reports/upload'  => 'reports#upload', :via => :post
  match 'release_notes'   => 'pages#release_notes', :via => :get
  match '/delayed_job_failures/read_all' => 'delayed_job_failures#read_all', :via => :post

  get 'radiator(.:format)' => 'radiator#index'

  get ':controller(/:action(/:id(.:format)))'

end
