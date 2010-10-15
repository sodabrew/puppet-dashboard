module NodeGroupGraph
  # Returns a hash of all the groups for this group/node, direct or inherited.
  # Each key is a group, and each value is the Set of groups from which we inherit
  # that group.
  def node_group_list
    return @node_group_list if @node_group_list
    all = {}
    self.walk_groups do |group,parents|
      parents.each do |parent|
        all[parent] ||= Set.new
        all[parent] << group
      end
      group
    end
    @node_group_list = all
  end

  # Returns a hash of all the classes for this group/node, direct or inherited.
  # Each key is a class, and each value is the Set of groups from which we inherit
  # that class.
  def node_class_list
    return @node_class_list if @node_class_list
    all = {}
    self.walk_groups do |group,_|
      group.node_classes.each do |node_class|
        all[node_class] ||= Set.new
        all[node_class] << group
      end
    end
    @node_class_list = all
  end

  def walk_groups(&block)
    walk(:node_groups,&block)
  end

  def walk_child_groups(&block)
    walk(:node_group_children,&block)
  end

  def node_group_graph
    @node_group_graph ||= compile_node_group_graph.last
  end

  private
  def compile_node_group_graph(group=self, seen=[], all=[])
    return [nil,{}] if seen.include? group
    all << group
    graph = group.node_groups.map {|grp| {grp => compile_node_group_graph(grp, seen + [group], all).last}}.inject({},&:merge)
    [all.uniq, graph]
  end

  def walk(method,&block)
    def yield_children(seen,method,&block)
      return nil if seen.include?(self)
      children_results = self.send(method).map{|group| group.yield_children(seen+[self],method,&block)}.compact
      yield self,children_results
    end
    return unless block
    seen = []
    yield_children(seen,method,&block)
  end
end
