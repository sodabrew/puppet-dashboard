class Node < ActiveRecord::Base
  include NodeGroupGraph

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships
  has_many :node_classes, :through => :node_class_memberships, :dependent => :destroy
  has_many :node_group_memberships
  has_many :node_groups, :through => :node_group_memberships

  has_parameters

  fires :created, :on => :create
  fires :updated, :on => :update
  fires :removed, :on => :destroy

  def available_node_classes
    @available_node_classes ||= NodeClass.all(:order => :name) - node_classes
  end

  def available_node_groups
    @available_node_groups ||= NodeGroup.all(:order => :name) - node_groups
  end

  def inherited_classes
    @inherited_classes ||= node_groups.map(&:node_classes).flatten
  end

  def all_classes
    node_classes | inherited_classes
  end

  def configuration
    { 'name' => name, 'classes' => node_classes.collect(&:name), 'parameters' => (parameters.blank? ? {} : parameters.to_hash) }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end

  def timeline_events
    TimelineEvent.find(:all,
                       :conditions => ["(subject_id = :id AND subject_type = :klass) OR (secondary_subject_id = :id AND secondary_subject_type = :klass)", {:id => id, :klass => self.class.name}],
                       :order => 'created_at DESC'
                      )
  end

  # Walks the graph of node groups for the given node, compiling parameters by
  # merging down (preferring parameters specified in node groups that are
  # nearer). Raises a ParameterConflictError if parameters at the same distance
  # from the node have the same name.
  def compiled_parameters
    return @compiled_parameters if @compiled_parameters
    seen_parameters = {}
    compile_parameters(self, 0, seen_parameters)
    @compiled_parameters = seen_parameters.sort_by{|key, value| key}.inject({}){|compiled, p| compiled.reverse_merge(p[1])}
  end

  def compile_parameters(object, depth, seen_parameters)
    object.parameters.each do |parameter|
      seen_parameters[depth] ||= {}
      raise ParameterConflictError if seen_parameters[depth][parameter.key]
      seen_parameters[depth][parameter.key] = parameter.value
    end

    object.node_groups.each{|group| compile_parameters(group, depth+1, seen_parameters)}
  end
end
