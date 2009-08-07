class ServicesController < ApplicationController
  resources_controller_for :service

  response_for :index do |format|
    format.html # index.rhtml
    format.js
    format.xml  { render :xml => resources }
    format.json { render :json => resources }
    format.yaml  { render :text => resources.to_yaml }
  end
end
