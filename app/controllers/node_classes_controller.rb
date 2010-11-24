class NodeClassesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_unless_using_external_node_classification

  include SearchableIndex
end
