ActionController::Routing::Routes.draw do |map|
  map.resources :nodes
  map.resources :services do |service|
    service.resources :nodes, :member => { :disconnect => :get, :connect => :get }
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
