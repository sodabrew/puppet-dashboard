class NodeClass < ActiveRecord::Base
  validates_presence_of :name
  validates_format_of :name, :with => /\A[a-z_\d]+\Z/i

  def self.search(query)
    return [] if query.blank?
    find(:all, :conditions => ["name like ?", "%#{query}%"])
  end
  
  def description; "No description" end
end
