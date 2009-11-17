module NodeGroupGraph
  def node_group_graph
    # return @node_group_grpah if @node_group_graph
    @node_group_graph = Hash[*node_groups.map{|group| [group, compile_node_group_graph(group)]}.flatten]
  end

  def compile_node_group_graph(group, seen=[])
    raise NodeGroupCycleError, group.inspect if seen.include?(group)
    seen << group
    Hash[*group.node_groups.map{|group| [group, compile_node_group_graph(group, seen)]}.flatten]
  end
end
