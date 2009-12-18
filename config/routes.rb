ActionController::Routing::Routes.draw do |map|
  map.resources :node_classes, :has_many => :nodes, :collection => {:search => :get}
  map.resources :node_groups, :has_many => :nodes, :collection => {:search => :get}

  map.resources :nodes, :member => {:performance => :get}, :has_many => :reports

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users

  map.resources :reports

  map.resource :status, :member => {:overview => :get}

  map.root :controller => :pages, :action => :home

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
