class Service < ActiveRecord::Base
  has_many :assignments
  has_many :nodes, :through => :assignments
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
