class Host < ActiveRecord::Base
  has_many :deployments
  has_many :instances, :through => :deployments

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def apps
    deployments.collect(&:app)
  end
  
  def customers
    deployments.collect(&:customer).flatten
  end
  
  def configuration
    instances.inject({ 'classes' => [], 'parameters' => {} }) do |h, instance|
      h['classes'] << instance.configuration_name
      h['parameters'][instance.configuration_name] = instance.configuration_parameters
      h
    end
  end
  
  def puppet_manifest
    result = ''
    instances.each do |instance|
      result += %Q(class #{instance.configuration_name} {"#{instance.configuration_name}":\n)
      instance.configuration_parameters.each_pair do |key, value|
        result += %Q(  $#{key} = "#{value}"\n)
      end
      instance.services.each do |service|
        result += %Q(  include #{service.configuration_name}\n)
      end
      result += "}\n"
      result += "include #{instance.configuration_name}\n"
    end
    result
  end
end
