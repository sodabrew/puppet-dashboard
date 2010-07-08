module PaginatedIndex
  def index
    index! do |format|
      format.html { paginate_collection! }
    end
  end
end
