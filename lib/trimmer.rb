module Trimmer
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def trimmed_fields *field_list
      before_validation do |model|
        field_list.each do |n|
          model[n] = model[n].strip if model[n].respond_to?('strip')
        end
      end
    end
  end
end
