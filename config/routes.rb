Rails.application.routes.draw do

  root 'pages#home'

  # Nodes, Groups, and Classes may all have names or numeric ids
  constraints(id: /[^\/]+/) do
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
      post :upload
    end
  end

  resources :delayed_job_failures, only: :index do
    member do
      post :read
    end
    collection do
      post :read_all
    end
  end

  resources :node_group_memberships, as: :memberships

  get 'files/diff/:file1/:file2', to: 'files#diff'
  get 'files/show/:file', to: 'files#show'

  get '/header.:format', to: 'pages#header'
  get 'release_notes', to: 'pages#release_notes'

  get 'radiator(.:format)', to: 'radiator#index'
end
