class Host < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  serialize :parameters
  
  def configuration
    { 'classes' => classes, 'parameters' => parameters }
  end
end
