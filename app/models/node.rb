class Node < ActiveRecord::Base
  include NodeGroupGraph

  named_scope :by_report_date, :order => 'reported_at DESC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships, :dependent => :destroy
  has_many :node_classes, :through => :node_class_memberships
  has_many :node_group_memberships, :dependent => :destroy
  has_many :node_groups, :through => :node_group_memberships

  has_many :reports

  has_parameters

  fires :created, :on => :create
  fires :updated, :on => :update
  fires :removed, :on => :destroy

  acts_as_url :name, :sync_url => true
  def to_param; name end

  def available_node_classes
    @available_node_classes ||= NodeClass.all(:order => :name) - node_classes - inherited_classes
  end

  def available_node_groups
    @available_node_groups ||= NodeGroup.all(:order => :name) - node_groups
  end

  def inherited_classes
    (node_group_list - [self]).map(&:node_classes).flatten.uniq
  end

  def all_classes
    node_classes | inherited_classes
  end

  def configuration
    { 'name' => name, 'classes' => all_classes.collect(&:name), 'parameters' => (parameters.blank? ? {} : parameters.to_hash) }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end

  def timeline_events
    TimelineEvent.for_node(self)
  end

  # Walks the graph of node groups for the given node, compiling parameters by
  # merging down (preferring parameters specified in node groups that are
  # nearer). Raises a ParameterConflictError if parameters at the same distance
  # from the node have the same name.
  def compiled_parameters(graph=node_group_graph, depth=1, seen_parameters={0 => parameters.to_hash})
    seen_parameters[depth] ||= {}
    graph.each do |parent, children_graph|
      parent.parameters.each do |parameter|
        raise ParameterConflictError if seen_parameters[depth][parameter.key] && seen_parameters[depth][parameter.key] != parameter.value
        seen_parameters[depth][parameter.key] = parameter.value
      end
      compiled_parameters(children_graph, depth+1, seen_parameters)
    end

    return seen_parameters.sort_by{|k,v| k}.inject({}){|results, array| depth, parameters = array; results.reverse_merge(parameters)}
  end


  # Placeholder attributes
  
  def environment
    'production'
  end

  def last_report
    reports.first(:order => :created_at)
  end
end
