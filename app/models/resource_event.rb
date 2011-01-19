class ResourceEvent < ActiveRecord::Base    
  belongs_to :resource_status

  serialize :desired_value
  serialize :previous_value
  serialize :historical_value
end
