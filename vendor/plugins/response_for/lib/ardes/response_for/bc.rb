module Ardes
  module ResponseFor
    module Bc
      def self.included(base)
        base.class_eval do
          alias_method_chain :template_exists?, :response_for
        end
      end
      
    protected
      def template_exists_with_response_for?
        action_responses.any? || template_exists_without_response_for?
      end
    end
  end
end