module NodeGroupGraph
  def node_group_graph
    @node_group_graph ||= compile_node_group_graph.last
  end

  def node_group_list
    @node_group_list ||= compile_node_group_graph.first
  end

  private
  def compile_node_group_graph(group=self, seen=[], all=[])
    return [nil,{}] if seen.include? group
    all << group
    graph = group.node_groups.map {|grp| {grp => compile_node_group_graph(grp, seen + [group], all).last}}.inject({},&:merge)
    [all.uniq, graph]
  end
end
