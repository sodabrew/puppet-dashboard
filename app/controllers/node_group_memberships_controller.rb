class NodeGroupMembershipsController < InheritedResources::Base
  respond_to :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :standardize_post_data, :only => [:create]

  def create
    create! do |success, failure|
      success.json { render :text => @node_group_membership.to_json, :content_type => 'application/json', :status => 201 }
      failure.json { render :text => {}.to_json, :content_type => 'application/json', :status => 422 }
    end
  end

  # we want: {node_group_membership => {node_id => <id>, node_group_id => <id>}
  # allow and convert: {node_name => <name>, group_name => <name>}
  def standardize_post_data
    unless params[:node_group_membership]
      params[:node_group_membership] = {}
      node  = Node.find_by_name(params[:node_name])
      group = NodeGroup.find_by_name(params[:group_name])
      params[:node_group_membership][:node_id] = (node && node.id)
      params[:node_group_membership][:node_group_id] = (group && group.id)
    end
  end
end
