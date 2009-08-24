class Node < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :assignments
  has_many :services, :through => :assignments
  
  serialize :parameters
  
  def configuration
    { 'classes' => services.collect(&:name), 'parameters' => parameters }
  end
end
