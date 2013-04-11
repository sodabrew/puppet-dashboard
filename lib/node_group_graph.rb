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

  def compile_class_parameters(class_membership, allow_conflicts=false)
    if @compiled_class_parameters.nil?
      @compiled_class_parameters = {}
    end

    unless @compiled_class_parameters[class_membership]
      compiled_parameters = self.walk_parent_groups do |group,parents|
        # Pick-up conflicts that our parents had
        parent_params = parents.map{|parent| parent[:parameters]}.flatten
        conflicts = parents.map{|parent| parent[:conflicts]}.inject(Set.new,&:merge)

        params = {}

        membership = if group.is_a? NodeGroup
                        NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(group.id, class_membership.node_class_id)
                      else
                        NodeClassMembership.find_by_node_id_and_node_class_id(group.id, class_membership.node_class_id)
                      end

        #If a parent group doesn't have the class declared, skip it
        if membership
          membership.parameters.each do |param|
            params[param.key] = { :name => param.key, :value => param.value, :sources => Set[group] }
          end
        end

        #Now collect our inherited params and their conflicts
        inherited = {}
        parent_params.each do |parameter|
          if inherited[parameter[:name]] && inherited[parameter[:name]][:value] != parameter[:value]
            conflicts.add(parameter[:name])
            inherited[parameter[:name]][:sources] << parameter[:sources].first
          else
            inherited[parameter[:name]] = { :name => parameter[:name], :value => parameter[:value], :sources => parameter[:sources] }
          end
        end

        # Resolve all conflicts resolved by the node/group itself
        conflicts.delete_if {|key| params[key]}

        { :parameters => params.reverse_merge(inherited).values.sort{|a,b| a[:name] <=> b[:name]}, :conflicts => conflicts.sort }
      end

      compiled_parameters[:conflicts].each { |key| errors.add(:classParameters, class_membership.node_class.name + "/" + key) }

      @compiled_class_parameters[class_membership] = compiled_parameters; 
    end

    raise ClassParameterConflictError unless allow_conflicts or @compiled_class_parameters[class_membership][:conflicts].empty?
    @compiled_class_parameters[class_membership][:parameters]
  end

  def compile_all_class_parameters
    unless @all_compiled_class_parameters
      @all_compiled_class_parameters = {}

      compiled_parameters = self.walk_parent_groups do |group,parents|

        parent_class_params = {}
        parents.select { |parent| !parent.empty?}.each do |parent|
          parent.each do |node_class, class_params|
            if parent_class_params[node_class].nil?
              parent_class_params[node_class] = []
            end

            parent_class_params[node_class] << class_params
            parent_class_params[node_class].flatten!
          end
        end

        merged_parent_class_params = {}
        parent_class_params.each do |node_class, class_params|
          merged_params = {}
          class_params.each do |param|
            if merged_params[param[:name]] &&
              (merged_params[param[:name]][:value] != param[:value] || merged_params[param[:name]][:sources].length > 1)
              merged_params[param[:name]][:sources].merge(param[:sources])
            else
              merged_params[param[:name]] = { :name => param[:name], :value => param[:value], :sources => param[:sources] }
            end
          end
          merged_parent_class_params[node_class] = merged_params
        end

        memberships = if group.is_a? NodeGroup
                        group.node_group_class_memberships
                      else
                        group.node_class_memberships
                      end

        memberships.each do |membership|

          if membership.parameters.length > 0
            params = {}

            membership.parameters.each do |param|
              params[param.key] = { :name => param.key, :value => param.value, :sources => Set[group] }
            end

            if merged_parent_class_params[membership.node_class].nil?
              merged_parent_class_params[membership.node_class] = params
            else
              merged_parent_class_params[membership.node_class].merge!(params)
            end
          end
        end

        resolved_class_params = {}
        merged_parent_class_params.each do |node_class, params|
          resolved_class_params[node_class] = params.values.sort{|a,b| a[:name] <=> b[:name]}
        end

        resolved_class_params
      end

      @all_compiled_class_parameters = compiled_parameters
    end

    @all_compiled_class_parameters
  end

  def node_classes_with_parameters
    return @node_classes_with_parameters if @node_classes_with_parameters
    all = {}
    self.walk_parent_groups do |group,_|
      group.node_classes.each do |node_class|
        node_class_parameters = Hash.new
        if group.class == NodeGroup
          if membership = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(group.id,node_class.id)
            self.compile_class_parameters(membership, false).each do |param|
              node_class_parameters[param[:name]] = param[:value]
            end
          end
        else
          if membership = NodeClassMembership.find_by_node_id_and_node_class_id(group.id,node_class.id)
            self.compile_class_parameters(membership, false).each do |param|
              node_class_parameters[param[:name]] = param[:value]
            end
          end
        end

        all[node_class.name] ||= Hash.new
        all[node_class.name] = node_class_parameters
      end
    end
    @node_classes_with_sources = all
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
        parent_params = parents.map{|parent| parent[:parameters]}.flatten
        conflicts = parents.map{|parent| parent[:conflicts]}.inject(Set.new,&:merge)

        params = {}
        group.parameters.to_hash.each do |key,value|
          params[key] = { :name => key, :value => value, :sources => Set[group] }
        end

        #Now collect our inherited params and their conflicts
        inherited = {}
        parent_params.each do |parameter|
          if inherited[parameter[:name]] && inherited[parameter[:name]][:value] != parameter[:value]
            conflicts.add(parameter[:name])
            inherited[parameter[:name]][:sources] << parameter[:sources].first
          else
            inherited[parameter[:name]] = { :name => parameter[:name], :value => parameter[:value], :sources => parameter[:sources] }
          end
        end

        # Resolve all conflicts resolved by the node/group itself
        conflicts.delete_if {|key| params[key]}

        { :parameters => params.reverse_merge(inherited).values.sort{|a,b| a[:name] <=> b[:name]}, :conflicts => conflicts.sort }
      end
      @compiled_parameters[:conflicts].each { |key| errors.add(:parameters,key) }
    end
    raise ParameterConflictError unless allow_conflicts or @compiled_parameters[:conflicts].empty?
    @compiled_parameters[:parameters]
  end

  def global_conflicts
    if @global_conflicts.nil?
      @global_conflicts = compiled_parameters(true).select { |param| param[:sources].length() > 1 }
    end

    @global_conflicts
  end

  def class_conflicts
    if @class_conflicts.nil?
      @class_conflicts = {}

      compile_all_class_parameters.each do |node_class, params|
        conflicting_params = params.select { |param| param[:sources].length > 1 }
        unless conflicting_params.blank?
          @class_conflicts[node_class] = conflicting_params
        end
      end
    end

    @class_conflicts
  end

  def parameter_list
    compiled_parameters.map{|param| {param[:name] => param[:value]} }.inject({},&:merge)
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
