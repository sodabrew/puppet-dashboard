class ResourceEvent < ActiveRecord::Base    
  belongs_to :resource_status

  serialize :tags, Array
  serialize :desired_value
  serialize :previous_value
end
