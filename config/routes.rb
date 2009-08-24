ActionController::Routing::Routes.draw do |map|
  map.resources :hosts, :services

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
