module Ardes
  module ActiveRecord
    module Saved
      # returns true if this record is not new, and has no errors
      def saved?
        !new_record? && (@errors.nil? || errors.empty?)
      end
      
      # returns true if this instance has had validation (maybe via save) attempted
      def validation_attempted?
        !@errors.nil?
      end
    end
  end
end