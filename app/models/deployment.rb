class Deployment < ActiveRecord::Base
  belongs_to :instance
  belongs_to :host
  
  validates_presence_of :instance
  validates_presence_of :host
  
  def app
    instance.app
  end
  
  def customer
    app.customer
  end
  
  def service
    instance.service
  end
  
  def required_services
    instance.required_services
  end
end
