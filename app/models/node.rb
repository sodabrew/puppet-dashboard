class Node < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships
  has_many :node_classes, :through => :node_class_memberships, :dependent => :destroy
  has_many :node_group_memberships
  has_many :node_groups, :through => :node_group_memberships

  has_parameters

  fires :created, :on => :create
  fires :updated, :on => :update
  fires :removed, :on => :destroy

  def available_node_classes
    @available_node_classes ||= NodeClass.all(:order => :name) - node_classes
  end

  def available_node_groups
    @available_node_groups ||= NodeGroup.all(:order => :name) - node_groups
  end

  def inherited_classes
    @inherited_classes ||= node_groups.map(&:node_classes).flatten
  end

  def all_classes
    node_classes | inherited_classes
  end

  def configuration
    { 'name' => name, 'classes' => node_classes.collect(&:name), 'parameters' => (parameters.blank? ? {} : parameters.to_hash) }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end

  def timeline_events
    TimelineEvent.find(:all,
                       :conditions => ["(subject_id = :id AND subject_type = :klass) OR (secondary_subject_id = :id AND secondary_subject_type = :klass)", {:id => id, :klass => self.class.name}],
                       :order => 'created_at DESC'
                      )
  end
end
