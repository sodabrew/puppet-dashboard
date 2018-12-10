class HelpController < ApplicationController
  def node_status
    respond_to do |format|
      format.html { render(partial: 'node_status') }
    end
  end
end
