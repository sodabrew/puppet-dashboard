ActionController::Routing::Routes.draw do |map|
  map.resources :node_classes, :collection => {:search => :get} do |classes|
    classes.resources :nodes, :requirements => {:id => /.*/}
  end

  map.resources :node_groups, :collection => {:search => :get} do |groups|
    groups.resources :nodes, :requirements => {:id => /.*/}
  end

  map.resources :nodes, 
    :member => {:reports => :get},
    :collection => {
     :successful => :get,
     :failed     => :get,
     :unreported => :get,
     :no_longer_reporting => :get},
    :requirements => {:id => /[^\/]+/}

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users

  map.resources :reports

  map.resource :status, :member => {:overview => :get}

  map.release_notes '/release_notes', :controller => :pages, :action => :release_notes

  map.root :controller => :pages, :action => :home

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
