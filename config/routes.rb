ActionController::Routing::Routes.draw do |map|
  map.resources :audits, :customers

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
