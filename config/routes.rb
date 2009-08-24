ActionController::Routing::Routes.draw do |map|
  map.resources :nodes, :services

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
