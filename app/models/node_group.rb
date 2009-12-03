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

  def self.search(query)
    return [] if query.blank?
    find(:all, :conditions => ["name like ?", "%#{query}%"])
  end
  
  def description; "No description" end

  def inspect; "#<NodeGroup id:#{id}, name:#{name.inspect}>" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end
end
