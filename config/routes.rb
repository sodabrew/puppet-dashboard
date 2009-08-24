ActionController::Routing::Routes.draw do |map|
  map.resources :edges, :hosts, :services

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
