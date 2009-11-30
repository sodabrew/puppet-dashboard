module NodeGroupGraph
  def node_group_graph
    return @node_group_graph if @node_group_graph
    generate_graph
    return @node_group_graph
  end

  def node_group_list
    return @node_group_list if @node_group_graph
    generate_graph
    return @node_group_list
  end


  private
  def generate_graph
    @node_group_list, @node_group_graph = compile_node_group_graph
  end

  def compile_node_group_graph(group=self, seen=[])
    raise NodeGroupCycleError, group.inspect if seen.include?(group)
    seen << group
    [seen, Hash[*group.node_groups.map{|group| [group, compile_node_group_graph(group, seen)]}.flatten]]
  end
end
