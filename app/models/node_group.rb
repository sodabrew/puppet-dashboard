class NodeGroup < ActiveRecord::Base
  def self.per_page; SETTINGS.groups_per_page end # Pagination

  include NodeGroupGraph
  extend FindFromForm
  extend FindByIdOrName

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

  default_scope -> { order('node_groups.name ASC') }

  scope :search, ->(name) { where('name LIKE ?', "%#{name}%") unless name.blank? }

  scope :with_nodes_count, -> do
    select('node_groups.*, count(nodes.id) as nodes_count').
    joins(<<-SQL,
      LEFT OUTER JOIN node_group_memberships ON (node_groups.id = node_group_memberships.node_group_id)
      LEFT OUTER JOIN nodes ON (nodes.id = node_group_memberships.node_id)
    SQL
    ).
    group('node_groups.id')
  end

  assigns_related :node_class, :node_group, :node

  def to_param
    SETTINGS.numeric_url_slugs ? id.to_s : name
  end

  def inspect; "#<NodeGroup id:#{id}, name:#{name.inspect}>" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end

  def <=>(rhs)
    self.name <=> rhs.name
  end
end
