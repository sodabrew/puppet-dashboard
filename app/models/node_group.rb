class NodeGroup < ActiveRecord::Base
  def self.per_page; 50 end # Pagination

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

  default_scope :order => 'name ASC'

  named_scope :search, lambda{|q| q.blank? ? {} : {:conditions => ['name LIKE ?', "%#{q}%"]} }

  named_scope :with_nodes_count,
    :select => 'node_groups.*, count(nodes.id) as nodes_count',
    :joins => 'LEFT OUTER JOIN node_group_memberships ON (node_groups.id = node_group_memberships.node_group_id) LEFT OUTER JOIN nodes ON (nodes.id = node_group_memberships.node_id)',
    :group => 'node_groups.id'

  def inspect; "#<NodeGroup id:#{id}, name:#{name.inspect}>" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end

  ['node', 'node_class', 'node_group'].each do |model|
    attr_accessor "#{model}_names"
    attr_accessor "#{model}_ids"
    before_validation "assign_#{model.pluralize}"

    define_method("assign_#{model.pluralize}") do
      names = instance_variable_get("@#{model}_names")
      ids = instance_variable_get("@#{model}_ids")
      begin
        return true unless ids || names
        raise NodeClassificationDisabledError.new unless SETTINGS.use_external_node_classification
        nodes = []
        nodes << model.camelize.constantize.find_from_form_names(*names) if names
        nodes << model.camelize.constantize.find_from_form_ids(*ids)     if ids

        send("#{model.pluralize}=", nodes.flatten.uniq)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        self.errors.add_to_base(e.message)
        return false
      end
    end
  end

  def <=>(rhs)
    self.name <=> rhs.name
  end
end
