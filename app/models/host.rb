class Host < ActiveRecord::Base
  has_many :deployments
  has_many :apps, :through => :deployments
  validates_presence_of :name
  validates_uniqueness_of :name

  def customers
    apps.collect(&:customer)
  end
end
