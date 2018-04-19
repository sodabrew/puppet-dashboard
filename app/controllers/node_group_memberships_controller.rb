class NodeGroupMembershipsController < InheritedResources::Base
  respond_to :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :standardize_post_data, :only => [:create]

  def create
    create!(node_group_membership_params) do |success, failure|
      success.json { render :json => @node_group_membership, :status => 201 }
      failure.json { render :json => {}, :status => 422 }
    end
  end

  # we want: {node_group_membership => {node_id => <id>, node_group_id => <id>}
  # allow and convert: {node_name => <name>, group_name => <name>}
  def standardize_post_data
    unless params[:node_group_membership]
      conv = params.permit(:node_name, :group_name)
      node  = Node.find_by_name(conv[:node_name])
      group = NodeGroup.find_by_name(conv[:group_name])
      params[:node_group_membership] = {}
      params[:node_group_membership][:node_id] = (node && node.id)
      params[:node_group_membership][:node_group_id] = (group && group.id)
    end
  end

  def node_group_membership_params
    params.require(:node_group_membership).permit(:node_id, :node_group_id)
  end
end
