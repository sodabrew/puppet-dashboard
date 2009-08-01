class App < ActiveRecord::Base
  belongs_to :customer
  has_many   :instances
  has_many   :deployments
  has_many :hosts, :through => :deployments
  validates_presence_of :name
  validates_presence_of :customer
end
