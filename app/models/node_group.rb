class NodeGroup < ActiveRecord::Base
  include NodeGroupGraph
  has_many :node_group_class_memberships
  has_many :node_classes, :through => :node_group_class_memberships

  has_many :node_group_memberships
  has_many :nodes, :through => :node_group_memberships

  has_many :node_group_edges, :foreign_key => 'from_id'
  has_many :node_groups, :through => :node_group_edges, :source => :to

  has_parameters

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.search(query)
    return [] if query.blank?
    find(:all, :conditions => ["name like ?", "%#{query}%"])
  end
  
  def description; "No description" end

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
