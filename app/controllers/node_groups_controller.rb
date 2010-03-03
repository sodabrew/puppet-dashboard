class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json

  before_filter :find_node_classes, :only => [:update, :create]

  update!{@node_group}

  def search
    @node_groups = NodeGroup.search(params[:val])
    render :json => @node_groups.to_json
  end

  private

  def content_id
    :inspector
  end
  helper_method :content_id

  def find_node_classes
    params[:node_group][:node_classes] ||= []
    return if params[:node_group][:node_classes].empty?
    params[:node_group][:node_classes] = NodeClass.find(params[:node_group][:node_classes])
  end

end
