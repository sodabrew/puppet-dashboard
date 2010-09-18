module SearchableIndex
  private

  def collection
    coll = end_of_association_chain.search(params[:q] || params[:tag])
    coll = paginate_scope(coll) if request.format == :html

    get_collection_ivar || set_collection_ivar(coll)
  end
end
