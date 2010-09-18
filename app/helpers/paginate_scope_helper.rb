module PaginateScopeHelper
  # Return a paginated +scope+.
  def paginate_scope(scope, opts={})
    opts.reverse_merge!(:page => params[:page])
    return scope.paginate(opts)
  end
end
