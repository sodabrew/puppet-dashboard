class Instance < ActiveRecord::Base
  belongs_to :app
  belongs_to :service
  has_one   :deployment
  
  validates_presence_of :app
  validates_presence_of :service
  
  def customer
    app.customer
  end
  
  def host
    deployment.host
  end
  
  def required_services
    [ service ] + service.depends_on
  end
end
