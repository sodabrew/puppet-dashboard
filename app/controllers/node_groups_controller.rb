class NodeGroupsController < InheritedResources::Base
  respond_to :html

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

end
