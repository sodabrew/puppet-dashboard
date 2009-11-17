module NodeGroupGraph
  def node_group_graph(group=self, seen=[])
    raise NodeGroupCycleError, group.inspect if seen.include?(group)
    seen << group
    Hash[*group.node_groups.map{|group| [group, node_group_graph(group, seen)]}.flatten]
  end
end
