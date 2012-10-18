PuppetDashboard::Application.routes do

  root :to => 'pages#home'
  
  resources :node_classes do
    collection do
      get :search
      resources :nodes, :constraints => {:id => /.*/}
    end
  end

  resources :node_groups do
    member do
      get :diff
    end
    collection do
      get :search
      resources :nodes, :constraints => {:id => /.*/}
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

  # FIXME: Not sure how to convert these to rails 3
  # map.upload "reports/upload", :controller => :reports, :action => "upload", :conditions => { :method => :post }
  # map.header '/header.:format', :controller => :pages, :action => :header

  match 'radiator' => 'radiator#index', :via => :get
  match 'release_notes' => 'pages#release_notes', :via => :get

  match ':controller/:action/:id'
  match ':controller/:action/:id.:format'
end
