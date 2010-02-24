class StatusesController < ApplicationController
  def overview
    render :layout => !request.xhr?
  end
end
