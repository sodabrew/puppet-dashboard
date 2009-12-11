class NodeClass < ActiveRecord::Base
  validates_presence_of :name
  validates_format_of :name, :with => /\A[a-z_\d:]+\Z/i
  validates_uniqueness_of :name

  def self.search(query)
    return [] if query.blank?
    find(:all, :conditions => ["name like ?", "%#{query}%"])
  end
  
  def description; "No description" end

  def to_json(options)
    super({:methods => :description, :only => [:name, :id]}.merge(options))
  end
end
