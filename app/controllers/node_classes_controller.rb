class NodeClassesController < InheritedResources::Base
  respond_to :html, :json

  include PaginatedIndex
  include PaginatedSearch

end
