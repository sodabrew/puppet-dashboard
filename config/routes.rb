ActionController::Routing::Routes.draw do |map|
  map.resources :node_classes, :collection => {:search => :get} do |classes|
    classes.resources :nodes, :requirements => {:id => /.*/}
  end

  map.resources :node_groups, :collection => {:search => :get} do |groups|
    groups.resources :nodes, :requirements => {:id => /.*/}
  end

  map.resources :nodes,
    :member => {
      :hide => :put,
      :unhide => :put,
      :facts => :get,
      :reports => :get},
    :collection => {
     :unreported => :get,
     :no_longer_reporting => :get,
     :hidden => :get,
     :search => :get},
    :requirements => {:id => /[^\/]+/}

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users

  map.resources :reports

  map.release_notes '/release_notes', :controller => :pages, :action => :release_notes

  map.root :controller => :pages, :action => :home

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
