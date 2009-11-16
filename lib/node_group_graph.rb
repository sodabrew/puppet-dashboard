module NodeGroupGraph
  def node_group_graph
    return @node_group_grpah if @node_group_graph
    @node_group_graph = {self => node_groups.map(&:compile_node_group_graph)}
  end

  def compile_node_group_graph(seen=[])
    raise NodeGroupCycleError if seen.include?(self)
    seen << self
    node_groups.map{|group| group.compile_node_group_graph(seen)}
  end
end
