class Instance < ActiveRecord::Base
  belongs_to :app
  has_one   :deployment
  has_one   :host, :through => :deployment
  
  has_many :requirements
  has_many :services, :through => :requirements
  
  validates_presence_of :app
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :app_id
  
  serialize :parameters
  
  def customer
    app.customer
  end

  def required_services
    (services + services.collect(&:depends_on)).flatten
  end
  
  def configuration_name
    [customer.name, app.name, name].join('__')
  end
  
  def configuration_parameters
    parameters || {}
  end
end
