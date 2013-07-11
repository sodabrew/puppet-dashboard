class PagesController < ApplicationController
  def home
    @all_nodes = Node.unhidden.custom_sort(params[:s], params[:o])

    @unreported_nodes         = @all_nodes.unreported
    @unresponsive_nodes       = @all_nodes.unresponsive
    @failed_nodes             = @all_nodes.failed
    @pending_nodes            = @all_nodes.pending
    @changed_nodes            = @all_nodes.changed
    @unchanged_nodes          = @all_nodes.unchanged
  end

  def header
    respond_to do |format|
      format.html { render :partial => 'shared/global_nav' }
    end
  end

end
