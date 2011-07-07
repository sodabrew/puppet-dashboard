module HasParameters
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def has_parameters(options={})
  

      include HasParameters::InstanceMethods

      has_many :parameters, {:as => :parameterable, :dependent => :destroy}.merge(options) do
        def to_hash
          Hash[*all.map{|p| [p.key, p.value]}.flatten]
        end
      end
    end
  end

  module InstanceMethods
    def parameter_attributes=(values)
      raise NodeClassificationDisabledError.new unless SETTINGS.use_external_node_classification
      new_parameters = values.reject{|v| v[:key].blank? && v[:value].blank?}.map do |hash|
        parameter = parameters.find_or_initialize_by_key(hash[:key])
        parameter.value = hash[:value]
        parameter.save
        parameter
      end
      self.parameters = new_parameters
    end
  end
end

ActiveRecord::Base.send(:include, HasParameters)
