class StatusesController < ApplicationController
  def show
    render :layout => !request.xhr?
  end
end
