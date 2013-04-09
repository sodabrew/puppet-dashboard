class NodeGroupClassMembershipsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_unless_using_external_node_classification
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex
  include ConflictAnalyzer
  include ConflictHtml

  def update
    update_helper :class => NodeGroupClassMembership,
                  :conflict_attribute => :node_group
  end

  def destroy
    destroy_helper  :class => NodeGroupClassMembership,
                    :owner_class => NodeGroup,
                    :conflict_attribute => :node_group
  end

end
