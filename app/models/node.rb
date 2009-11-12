class Node < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships
  has_many :node_classes, :through => :node_class_memberships, :dependent => :destroy
  has_many :node_group_memberships
  has_many :node_groups, :through => :node_group_memberships

  has_many :parameters, :as => :parameterable, :dependent => :destroy do
    def to_hash
      Hash[*target.map{|p| [p.key, p.value]}.flatten]
    end
  end

  def parameter_attributes=(values)
    new_parameters = values.reject{|v| v[:key].blank? && v[:value].blank?}.map do |hash|
      returning(Parameter.find_or_initialize_by_key(hash[:key])) do |parameter|
        parameter.value = hash[:value]
        parameter.save
      end
    end
    self.parameters = (new_parameters)
  end

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
    { 'classes' => node_classes.collect(&:name), 'parameters' => (parameters.blank? ? {} : parameters.to_hash) }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end
end
