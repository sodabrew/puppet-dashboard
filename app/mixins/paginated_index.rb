module PaginatedIndex
  def index
    index! do |format|
      format.html { set_collection_ivar(get_collection_ivar.paginate(:page => params[:page])) }
    end
  end
end
