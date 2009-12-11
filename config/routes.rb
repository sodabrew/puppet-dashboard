ActionController::Routing::Routes.draw do |map|
  map.resources :node_classes, :has_many => :nodes, :collection => {:search => :get}
  map.resources :node_groups, :has_many => :nodes, :collection => {:search => :get}

  map.resources :nodes

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users

  map.resources :reports

  map.resource :status

  map.root :controller => :pages, :action => :home

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
