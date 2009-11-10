class Node < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships
  has_many :node_classes, :through => :node_class_memberships, :dependent => :destroy
  has_many :node_group_memberships
  has_many :node_groups, :through => :node_group_memberships

  has_many :parameters_store, :class_name => 'Parameter', :as => :parameterable, :dependent => :destroy do
    def to_hash
      Hash[*target.map{|p| [p.key, p.value]}.flatten]
    end

    def from_hash(hash)
      new_parameters = hash.enum_for(:each).map do |key, value|
        key, value = key.to_s, value.to_s
        Parameter.find_or_initialize_by_key(key) do |parameter|
          parameter.value = value
        end
      end
      replace(new_parameters)
    end
  end

  def parameters
    parameters_store.to_hash
  end

  def parameters=(hash)
    parameters_store.from_hash(hash)
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
    { 'classes' => node_classes.collect(&:name), 'parameters' => (parameters || {}).to_hash }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end
end
