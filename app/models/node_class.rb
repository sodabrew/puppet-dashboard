class NodeClass < ActiveRecord::Base
  validates_presence_of :name
  validates_format_of :name, :with => /\A[a-z_\d]+\Z/i

  def description; "No description" end
end
