PuppetDashboard::Application.routes do

  root :to => 'pages#home'
  
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

  constraints(:id => /[^\/]+/) do
    resources :nodes do
      member do
        put :hide
        put :unhide
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

  resources :reports do
    collection do
      get :search
      get :all
      get :failed
      get :pending
      get :changed
      get :unchanged
    end
  end

  resources :node_group_memberships, :as => :memberships

  match 'files/:action/:file1/:file2' => 'files#:action'
  match 'files/:action/:file'         => 'files#:action'

  match '/header.:format' => 'pages#header'
  match 'reports/upload'  => 'reports#upload', :via => :post
  match 'release_notes'   => 'pages#release_notes', :via => :get
  match '/delayed_job_failures/read_all' => 'delayed_job_failures#read_all', :via => :post

  get ':controller(/:action(/:id(.:format)))'

end
