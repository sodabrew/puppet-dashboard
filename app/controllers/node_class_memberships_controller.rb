class NodeClassMembershipsController < InheritedResources::Base
  respond_to :html, :json
  before_action :raise_unless_using_external_node_classification
  before_action :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex
  include ConflictAnalyzer
  include ConflictHtml

  def update
    update_helper :class => NodeClassMembership,
                  :conflict_attribute => :node
  end

  def destroy
    destroy_helper  :class => NodeClassMembership,
                    :owner_class => Node,
                    :conflict_attribute => :node
  end

end
