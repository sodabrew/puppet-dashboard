module NodeGroupsHelper
  def node_groups
    @node_groups ||= NodeGroup.all
  end
end
