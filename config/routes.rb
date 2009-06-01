ActionController::Routing::Routes.draw do |map|
  map.resources :apps, :audits, :customers

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
