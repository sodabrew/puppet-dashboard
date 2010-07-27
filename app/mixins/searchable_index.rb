module SearchableIndex
  private

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.search(params[:q] || params[:tag]))
  end
end
