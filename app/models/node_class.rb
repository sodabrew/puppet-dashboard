class NodeClass < ActiveRecord::Base
  def self.per_page; SETTINGS.classes_per_page end # Pagination

  include NodeGroupGraph
  extend FindFromForm
  extend FindByIdOrName

  has_many :node_group_class_memberships, :dependent => :destroy
  has_many :node_class_memberships, :dependent => :destroy

  has_many :node_group_children, :class_name => "NodeGroup", :through => :node_group_class_memberships, :source => :node_group
  has_many :nodes, :through => :node_class_memberships

  validates_presence_of :name

  validates_format_of :name, :with => /\A([a-z0-9][-\w]*)(::[a-z0-9][-\w]*)*\Z/, :message => "must contain a valid Puppet class name, e.g. 'foo' or 'foo::bar'"
  validates_uniqueness_of :name
  attr_accessible :name, :description

  default_scope :order => 'node_classes.name ASC'

  scope :search, lambda{|q| where('name LIKE ?', "%#{q}%") unless q.blank? }

  scope :with_nodes_count,
    :select => 'node_classes.*, count(nodes.id) as nodes_count',
    :joins => <<-SQL,
      LEFT OUTER JOIN node_class_memberships ON (node_classes.id = node_class_memberships.node_class_id)
      LEFT OUTER JOIN nodes ON (nodes.id = node_class_memberships.node_id)
    SQL
    :group => 'node_classes.id'

  def to_param
    SETTINGS.numeric_url_slugs ? id.to_s : name
  end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end

  def <=>(rhs)
    self.name <=> rhs.name
  end
end
