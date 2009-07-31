ActionController::Routing::Routes.draw do |map|
  map.resources :apps, :customers, :deployments, :destinations, :edges, :hosts, :instances, :services

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
