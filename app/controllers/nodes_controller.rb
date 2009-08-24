class NodesController < ApplicationController
  resources_controller_for :node
  
  response_for :show do |format|
    format.html # show.rhtml
    format.yaml  { render :text => resource.configuration.to_yaml }
  end  
end
