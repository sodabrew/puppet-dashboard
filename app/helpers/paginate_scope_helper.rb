require 'will_paginate/array'

module PaginateScopeHelper
  # Return a paginated +scope+.
  def paginate_scope(scope, opts={})
    if ! params[:per_page]
      per_page = scope.first.class.per_page rescue nil
      page = params[:page]
    elsif params[:per_page] == 'all'
      per_page = scope.count
      page = 1
    else
      per_page = params[:per_page]
      page = begin
          if per_page.to_i * params[:page].to_i > scope.count
            scope.count / per_page.to_i + 1 # last page
          else
            params[:page]
          end
        rescue StandardError
          params[:page]
        end
    end

    # Handle negative / invalid page numbers gracefully
    page = (page.to_i > 0 ? page : 1) rescue 1
    per_page = (per_page.to_i > 0 ? per_page : nil) rescue nil

    scope.paginate( opts.reverse_merge(:page => page, :per_page => per_page) )
  end
end
