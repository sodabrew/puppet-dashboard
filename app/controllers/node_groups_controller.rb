class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex

  def new
    new! do |format|
      format.html {
        set_node_autocomplete_data_sources(@node_group)
        set_group_and_class_autocomplete_data_sources(@node_group)
      }
    end
  end

  def create
    create! do |success, failure|
      failure.html {
        set_node_autocomplete_data_sources(@node_group)
        set_group_and_class_autocomplete_data_sources(@node_group)
        render :new
      }
    end
  end

  def edit
    edit! do |format|
      format.html {
        set_node_autocomplete_data_sources(@node_group)
        set_group_and_class_autocomplete_data_sources(@node_group)
      }
    end
  end

  def update
    update! do |success, failure|
      failure.html {
        set_node_autocomplete_data_sources(@node_group)
        set_group_and_class_autocomplete_data_sources(@node_group)
        render :edit
      }
    end
  end

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_id_or_name!(params[:id]))
  end
end
