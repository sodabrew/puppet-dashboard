class NodeGroup < ActiveRecord::Base
  def self.per_page; SETTINGS.groups_per_page end # Pagination

  include NodeGroupGraph
  extend FindFromForm

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
  attr_accessible :name, :assigned_node_group_ids, :assigned_node_ids, :assigned_node_class_ids
  attr_accessible :node_group_ids, :node_ids, :parameter_attributes, :node_class_ids

  default_scope :order => 'node_groups.name ASC'

  scope :search, lambda{|q| where('name LIKE ?', "%#{q}%") unless q.blank? }

  scope :with_nodes_count,
    :select => 'node_groups.*, count(nodes.id) as nodes_count',
    :joins => 'LEFT OUTER JOIN node_group_memberships ON (node_groups.id = node_group_memberships.node_group_id) LEFT OUTER JOIN nodes ON (nodes.id = node_group_memberships.node_id)',
    :group => 'node_groups.id'

  assigns_related :node_class, :node_group, :node

  def inspect; "#<NodeGroup id:#{id}, name:#{name.inspect}>" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end

  def <=>(rhs)
    self.name <=> rhs.name
  end
end
