class Node < ActiveRecord::Base
  def self.per_page; 20 end # Pagination

  include NodeGroupGraph

  default_scope :order => 'name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships, :dependent => :destroy
  has_many :node_classes, :through => :node_class_memberships
  has_many :node_group_memberships, :dependent => :destroy
  has_many :node_groups, :through => :node_group_memberships

  has_many :reports, :dependent => :destroy
  has_one :last_report, :class_name => 'Report', :order => 'time DESC'

  named_scope :by_report_date, :order => 'reported_at DESC'

  named_scope :search, lambda{|q| q.blank? ? {} : {:conditions => ['name LIKE ?', "%#{q}%"]} }

  # ordering scopes for has_scope
  named_scope :by_latest_report, proc { |order| 
    direction = {1 => 'ASC', 0 => 'DESC'}[order]
    direction ? {:order => "reported_at #{direction}"} : {}
  }

  has_parameters

  fires :created, :on => :create
  fires :updated, :on => :update
  fires :removed, :on => :destroy

  # RH:TODO: Denormalize last report status into nodes table.
  named_scope :successful, :select => 'DISTINCT `nodes`.name, `nodes`.*', :joins => 'INNER JOIN reports on reports.time = reported_at', :conditions => 'reports.success = 1 AND (`nodes`.id = reports.node_id)', :order => "reported_at DESC"
  named_scope :failed, :select => 'DISTINCT `nodes`.name, `nodes`.*', :joins => 'LEFT OUTER JOIN reports on reports.time = reported_at', :conditions => 'reports.success = 0 AND (`nodes`.id = reports.node_id)', :order => "reported_at DESC"

  named_scope :unreported, :conditions => {:reported_at => nil}
  named_scope :no_longer_reporting, :conditions => ['reported_at < ?', 30.minutes.ago]

  def self.count_successful
    successful.count(:name, :distinct => true)
  end

  def self.count_failed
    failed.count(:name, :distinct => true)
  end

  def self.count_unreported
    unreported.count
  end

  def to_param
    name.to_s
  end

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
    { 'name' => name, 'classes' => all_classes.collect(&:name), 'parameters' => compiled_parameters }
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
    return @compiled_parameters if @compiled_parameters

    seen_parameters[depth] ||= {}
    graph.each do |parent, children_graph|
      parent.parameters.each do |parameter|
        raise ParameterConflictError if seen_parameters[depth][parameter.key] && seen_parameters[depth][parameter.key] != parameter.value
        seen_parameters[depth][parameter.key] = parameter.value
      end
      compiled_parameters(children_graph, depth+1, seen_parameters)
    end

    return @compiled_parameters = parameters.to_hash.reverse_merge(seen_parameters.sort_by{|k,v| k}.inject({}){|results, array| depth, parameters = array; results.reverse_merge(parameters)})
  end


  # Placeholder attributes
  
  def environment
    'production'
  end

  def status_class
    return 'no reports' unless last_report
    last_report.status
  end

  attr_accessor :node_class_names
  after_save :assign_node_classes
  def assign_node_classes
    return true unless @node_class_names
    self.node_classes = (@node_class_names || []).reject(&:blank?).map{|name| NodeClass.find_by_name(name)}
  end

  attr_accessor :node_group_names
  after_save :assign_node_groups
  def assign_node_groups
    return true unless @node_group_names
    self.node_groups = (@node_group_names || []).reject(&:blank?).map{|name| NodeGroup.find_by_name(name)}
  end
end
