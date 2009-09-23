class Node < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :node_class_memberships
  has_many :node_classes, :through => :node_class_memberships
  has_many :node_group_memberships
  has_many :node_groups, :through => :node_group_memberships
  
  serialize :parameters

  def available_node_classes
    @available_node_classes ||= NodeClass.all(:order => :name) - node_classes
  end
  
  def available_node_groups
    @available_node_groups ||= NodeGroup.all(:order => :name) - node_groups
  end
  
  def configuration
    { 'classes' => node_classes.collect(&:name), 'parameters' => parameters }
  end

  def before_save
    logger.debug "ATTRIBUTES: #{attributes.inspect}"
  end
end
