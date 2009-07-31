class Customer < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :apps
  
  def hosts
    apps.collect(&:hosts).flatten
  end
end
