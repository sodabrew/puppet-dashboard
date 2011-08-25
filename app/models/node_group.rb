class NodeGroup < ActiveRecord::Base
  def self.per_page; 50 end # Pagination

  include NodeGroupGraph

  has_many :node_group_class_memberships, :dependent => :destroy
  has_many :node_classes, :through => :node_group_class_memberships

  has_many :node_group_memberships, :dependent => :destroy
  has_many :nodes, :through => :node_group_memberships

  has_many :node_group_edges_out, :class_name => "NodeGroupEdge", :foreign_key => 'from_id', :dependent => :destroy
  has_many :node_group_edges_in, :class_name => "NodeGroupEdge", :foreign_key => 'to_id', :dependent => :destroy

  has_many :node_group_children, :class_name => "NodeGroup", :through => :node_group_edges_in, :source => :from
  has_many :node_group_parents, :class_name => "NodeGroup", :through => :node_group_edges_out, :source => :to

  # Alias for compatibility with Node
  alias :node_groups :node_group_parents
  alias :node_groups= :node_group_parents=

  has_parameters

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope :order => 'name ASC'

  named_scope :search, lambda{|q| q.blank? ? {} : {:conditions => ['name LIKE ?', "%#{q}%"]} }

  named_scope :with_nodes_count,
    :select => 'node_groups.*, count(nodes.id) as nodes_count',
    :joins => 'LEFT OUTER JOIN node_group_memberships ON (node_groups.id = node_group_memberships.node_group_id) LEFT OUTER JOIN nodes ON (nodes.id = node_group_memberships.node_id)',
    :group => 'node_groups.id'

  def inspect; "#<NodeGroup id:#{id}, name:#{name.inspect}>" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end

  attr_accessor :node_names
  attr_accessor :node_ids
  before_validation :assign_nodes
  def assign_nodes
    return true unless @node_ids || @node_names
    raise NodeClassificationDisabledError.new unless SETTINGS.use_external_node_classification
    nodes = []
    nodes << Node.find_from_form_names(*@node_names) if @node_names
    nodes << Node.find_from_form_ids(*@node_ids)     if @node_ids

    self.nodes = nodes.flatten.uniq
  rescue ActiveRecord::RecordInvalid => e
    self.errors.add_to_base(e.message)
    return false
  end

  attr_accessor :node_class_names
  attr_accessor :node_class_ids
  before_validation :assign_node_classes
  def assign_node_classes
    return true unless @node_class_ids || @node_class_names
    raise NodeClassificationDisabledError.new unless SETTINGS.use_external_node_classification
    node_classes = []
    node_classes << NodeClass.find_from_form_names(*@node_class_names) if @node_class_names
    node_classes << NodeClass.find_from_form_ids(*@node_class_ids)     if @node_class_ids

    self.node_classes = node_classes.flatten.uniq
  rescue ActiveRecord::RecordInvalid => e
    self.errors.add_to_base(e.message)
    return false
  end

  attr_accessor :node_group_names
  attr_accessor :node_group_ids
  before_validation :assign_node_groups
  def assign_node_groups
    return true unless @node_group_ids || @node_group_names
    node_groups = []
    node_groups << NodeGroup.find_from_form_names(*@node_group_names) if @node_group_names
    node_groups << NodeGroup.find_from_form_ids(*@node_group_ids)     if @node_group_ids

    self.node_groups = node_groups.flatten.uniq
  rescue ActiveRecord::RecordInvalid => e
    self.errors.add_to_base(e.message)
    return false
  end

  def self.find_from_form_names(*names)
    names.reject(&:blank?).map{|name| self.find_by_name(name)}.uniq
  end

  def self.find_from_form_ids(*ids)
    ids.map{|entry| entry.to_s.split(/[ ,]/)}.flatten.reject(&:blank?).uniq.map{|id| self.find(id)}
  end

  def <=>(rhs)
    self.name <=> rhs.name
  end
end
