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
      :hide    => :put,
      :unhide  => :put,
      :facts   => :get,
      :reports => :get},
    :collection => {
     :unreported   => :get,
     :failed       => :get,
     :pending      => :get,
     :unresponsive => :get,
     :changed      => :get,
     :unchanged    => :get,
     :hidden       => :get,
     :search       => :get},
    :requirements => {:id => /[^\/]+/}

  map.resources :reports,
    :collection => {
      :search => :get,
    }

  map.resources :node_group_memberships, :as => :memberships

  map.upload "reports/upload", :controller => :reports, :action => "upload", :conditions => { :method => :post }

  map.release_notes '/release_notes', :controller => :pages, :action => :release_notes

  map.header '/header.:format', :controller => :pages, :action => :header

  map.root :controller => :pages, :action => :home

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
