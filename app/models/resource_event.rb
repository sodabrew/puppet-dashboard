class ResourceEvent < ActiveRecord::Base
  belongs_to :resource_status

  serialize :desired_value
  serialize :previous_value
  serialize :historical_value

  # The "natural" order of properties is that 'ensure' comes before anything
  # else, then alphabetically sorted by the property name.
  def <=>(that)
    [self.property == 'ensure' ? 0 : 1, self.property] <=>
      [that.property == 'ensure' ? 0 : 1, that.property]
  end
end
