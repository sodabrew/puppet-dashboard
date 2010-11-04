require 'ostruct'

module NodeGroupGraph
  def all_node_groups
    node_groups_with_sources.keys
  end

  # Returns a hash of all the groups for this group/node, direct or inherited.
  # Each key is a group, and each value is the Set of groups from which we inherit
  # that group.
  def node_groups_with_sources
    return @node_groups_with_sources if @node_groups_with_sources
    all = {}
    self.walk_parent_groups do |group,parents|
      parents.each do |parent|
        all[parent] ||= Set.new
        all[parent] << group
      end
      group
    end
    @node_groups_with_sources = all
  end

  def all_node_group_children
    node_group_children_with_sources.keys
  end

  def node_group_children_with_sources
    return @node_group_children_with_sources if @node_group_children_with_sources
    all = {}
    self.walk_child_groups do |group,children|
      children.each do |child|
        all[child] ||= Set.new
        all[child] << group
      end
      group
    end
    @node_group_children_with_sources = all
  end

  def all_node_classes
    node_classes_with_sources.keys
  end

  # Returns a hash of all the classes for this group/node, direct or inherited.
  # Each key is a class, and each value is the Set of groups from which we inherit
  # that class.
  def node_classes_with_sources
    return @node_classes_with_sources if @node_classes_with_sources
    all = {}
    self.walk_parent_groups do |group,_|
      group.node_classes.each do |node_class|
        all[node_class] ||= Set.new
        all[node_class] << group
      end
    end
    @node_classes_with_sources = all
  end

  def all_nodes
    nodes_with_sources.keys
  end

  def nodes_with_sources
    return @nodes_with_sources if @nodes_with_sources
    all = {}
    self.walk_child_groups do |group,_|
      group.nodes.each do |node|
        all[node] ||= Set.new
        all[node] << group
      end
    end
    @nodes_with_sources = all
  end

  # Collects all the parameters of the node, starting at the "most distant" groups
  # and working its ways up to the node itself. If there is a conflict between two
  # groups at the same level, the conflict is deferred to the next level. If the
  # conflict reaches the top without being resolved, a ParameterConflictError is
  # raised.
  def compiled_parameters(allow_conflicts=false)
    unless @compiled_parameters
      @compiled_parameters = self.walk_parent_groups do |group,parents|
        # Pick-up conflicts that our parents had
        parent_params = parents.map(&:parameters).flatten
        conflicts = parents.map(&:conflicts).inject(Set.new,&:merge)

        params = {}
        group.parameters.to_hash.each do |key,value|
          params[key] = OpenStruct.new :name => key, :value => value, :sources => Set[group]
        end

        #Now collect our inherited params and their conflicts
        inherited = {}
        parent_params.each do |parameter|
          if inherited[parameter.name] && inherited[parameter.name].value != parameter.value
            conflicts.add(parameter.name)
            inherited[parameter.name].sources << parameter.sources.first
          else
            inherited[parameter.name] = OpenStruct.new :name => parameter.name, :value => parameter.value, :sources => parameter.sources
          end
        end

        # Resolve all conflicts resolved by the node/group itself
        conflicts.delete_if {|key| params[key]}

        OpenStruct.new :parameters => params.reverse_merge(inherited).values, :conflicts => conflicts
      end
      @compiled_parameters.conflicts.each { |key| errors.add(:parameters,key) }
    end
    raise ParameterConflictError unless allow_conflicts or @compiled_parameters.conflicts.empty?
    @compiled_parameters.parameters
  end

  def parameter_list
    compiled_parameters.map{|param| {param.name => param.value} }.inject({},&:merge)
  end

  def walk_parent_groups(&block)
    walk(:node_groups,&block)
  end

  def walk_child_groups(&block)
    walk(:node_group_children,&block)
  end

  private

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
