module NodeGroupGraph
  def node_group_graph
    return @node_group_graph if @node_group_graph
    @node_group_list, @node_group_graph = compile_node_group_graph
    return @node_group_graph
  end

  def node_group_list
    return @node_group_list if @node_group_graph
    @node_group_list, @node_group_graph = compile_node_group_graph
    return @node_group_list
  end


  private
  def compile_node_group_graph(group=self, seen=[])
    raise NodeGroupCycleError, group.inspect if seen.include?(group)
    seen << group
    graph = Hash[*group.node_groups.map{|group| [group, compile_node_group_graph(group, seen).last]}.flatten]
    [seen, graph]
  end
end
