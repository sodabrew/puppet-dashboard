class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json

  include SearchableIndex
end
