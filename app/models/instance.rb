class Instance < ActiveRecord::Base
  belongs_to :app
  has_one   :deployment
  
  has_many :requirements
  has_many :services, :through => :requirements
  
  validates_presence_of :app
  
  def customer
    app.customer
  end
  
  def host
    deployment.host
  end
  
  def required_services
    (services + services.collect(&:depends_on)).flatten
  end
end
