class NodeClass < ActiveRecord::Base
  has_many :node_class_memberships
  has_many :nodes, :through => :node_class_memberships

  validates_presence_of :name
  validates_format_of :name, :with => /\A[a-z_\d:]+\Z/i
  validates_uniqueness_of :name

  named_scope :search, lambda{|q| q.blank? ? {} : {:conditions => ['name LIKE ?', "%#{q}%"]} }

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end
end
