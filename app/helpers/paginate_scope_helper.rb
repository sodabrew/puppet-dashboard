module PaginateScopeHelper
  # Return a paginated +scope+.
  def paginate_scope(scope, opts={})
    if ! params[:per_page]
      scope.paginate( opts.reverse_merge(:page => params[:page], :per_page => (scope.first.class.per_page rescue nil)) )
    elsif params[:per_page] != "all"
      scope.paginate( opts.reverse_merge(:page => params[:page], :per_page => params[:per_page]) )
    else
      scope.paginate( opts.reverse_merge(:page => 1, :per_page => scope.count) )
    end
  end
end
