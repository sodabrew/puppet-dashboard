class ResourceEvent < ApplicationRecord
  belongs_to :resource_status

  # Only perform YAMLization on non-strings.
  class ValueWrapper
    def self.load(val)
      begin
        if val.start_with?('---')
          YAML.load(val)
        else
          val
        end
      rescue StandardError
        val
      end
    end

    def self.dump(val)
      val.is_a?(String) ? val : YAML.dump(val)
    end
  end

  serialize :desired_value, ValueWrapper
  serialize :previous_value, ValueWrapper
  serialize :historical_value, ValueWrapper

  # The "natural" order of properties is that 'ensure' comes before anything
  # else, then alphabetically sorted by the property name.
  def <=>(that)
    [self.property == 'ensure' ? 0 : 1, self.property] <=>
      [that.property == 'ensure' ? 0 : 1, that.property]
  end
end
