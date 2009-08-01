class Host < ActiveRecord::Base
  has_many :deployments

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def apps
    deployments.collect(&:app)
  end
  
  def customers
    deployments.collect(&:customer).flatten
  end
end
