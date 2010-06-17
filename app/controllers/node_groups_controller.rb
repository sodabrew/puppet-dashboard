class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json

  include JsonIndex
  include PaginatedSearch

end
