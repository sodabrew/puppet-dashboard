class StatusesController < ApplicationController
  layout 'application'
  def overview
    render :layout => !request.xhr?
  end
end
