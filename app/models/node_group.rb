class NodeGroup < ActiveRecord::Base
  include NodeGroupGraph
  has_many :node_group_class_memberships, :dependent => :destroy
  has_many :node_classes, :through => :node_group_class_memberships

  has_many :node_group_memberships, :dependent => :destroy
  has_many :nodes, :through => :node_group_memberships

  has_many :node_group_edges_out, :class_name => "NodeGroupEdge", :foreign_key => 'from_id', :dependent => :destroy
  has_many :node_group_edges_in, :class_name => "NodeGroupEdge", :foreign_key => 'to_id', :dependent => :destroy

  # TODO Want to add a list of groups have edges into us, may want to rename node_groups
  has_many :node_groups, :through => :node_group_edges_out, :source => :to

  has_parameters

  validates_presence_of :name
  validates_uniqueness_of :name

  named_scope :search, lambda{|q| q.blank? ? {} : {:conditions => ['name LIKE ?', "%#{q}%"]} }

  named_scope :with_nodes_count,
    :select => 'node_groups.*, count(nodes.id) as nodes_count',
    :joins => 'LEFT OUTER JOIN node_group_memberships ON (node_groups.id = node_group_memberships.node_group_id) LEFT OUTER JOIN nodes ON (nodes.id = node_group_memberships.node_id)',
    :group => 'node_groups.id'

  def inspect; "#<NodeGroup id:#{id}, name:#{name.inspect}>" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end

  attr_accessor :node_class_names
  after_save :assign_node_classes
  def assign_node_classes
    self.node_classes = (@node_class_names || []).map{|name| NodeClass.find_by_name(name)}
  end

  attr_accessor :node_group_names
  after_save :assign_node_groups
  def assign_node_groups
    self.node_groups = (@node_group_names || []).map{|name| NodeGroup.find_by_name(name)}
  end

end
