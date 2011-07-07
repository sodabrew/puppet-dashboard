class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex

  def edit
    edit! do |format|
      format.html {
        if SETTINGS.use_external_node_classification
          @class_data = {:class => '#node_class_ids', :data_source => node_classes_path(:format => :json), :objects => @node_group.node_classes}
        end
        @group_data = {:class => '#node_group_ids', :data_source => node_groups_path(:format => :json),  :objects => @node_group.node_groups}
      }
    end
  end
end
