class NodeGroupsController < InheritedResources::Base
  respond_to :html

  update!{@node_group}

  private

  def content_id
    :inspector
  end
  helper_method :content_id

end
