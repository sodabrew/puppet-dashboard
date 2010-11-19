module PaginateScopeHelper
  # Return a paginated +scope+.
  def paginate_scope(scope, opts={})
    if ! params[:per_page]
      scope.paginate( opts.reverse_merge(:page => params[:page]) )
    elsif params[:per_page] != "all"
      scope.paginate( opts.reverse_merge(:page => params[:page], :per_page => params[:per_page]) )
    else
      scope
    end
  end
end
