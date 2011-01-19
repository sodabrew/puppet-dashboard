ActionController::Routing::Routes.draw do |map|
  map.resources :node_classes, :collection => {:search => :get} do |classes|
    classes.resources :nodes, :requirements => {:id => /.*/}
  end

  map.resources :node_groups,
    :member     => { :diff  => :get },
    :collection => {:search => :get } do |groups|
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

  map.resources :reports,
    :member => {
      :diff => :get,
      :make_baseline => :put,
    },
    :collection => {
      :search => :get,
    }

  map.upload "reports/upload", :controller => :reports, :action => "upload", :conditions => { :method => :post }

  map.release_notes '/release_notes', :controller => :pages, :action => :release_notes

  map.root :controller => :pages, :action => :home

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
