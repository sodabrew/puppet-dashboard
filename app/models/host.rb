class Host < ActiveRecord::Base
  has_many :deployments
  validates_presence_of :name
  validates_uniqueness_of :name
end
