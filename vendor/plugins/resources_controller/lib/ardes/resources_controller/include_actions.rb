module Ardes
  module ResourcesController
    # extension for any module that is used as an Actions module.
    #
    # After extending the module (say 'MyActions'), instead of doing this:
    #   self.include ActionsModule
    # do this:
    #   ActionsModule.include_actions(self, <:only or :except options>)
    #
    # RC extends any actions module with this automatically, so you don't need to know about it.
    #
    # However, if you ahve any special behaviour in your actions module that is sensitive to
    # :only and :except, you can define your own include_actions method on that module
    # to effect this special behaviour.
    module IncludeActions
      def include_actions(controller, options = {})
        options.assert_valid_keys(:only, :except)
        raise ArgumentError, "you can only specify either :except or :only, not both" if options[:only] && options[:except]
        mixin = self.clone
        action_methods_to_remove(options).each {|a| mixin.remove_action_method(a) }
        controller.send :include, mixin
      end
      
      def remove_action_method(action)
        undef_method action
      end
      
      def action_methods_to_remove(options = {})
        if options[:only]
          instance_methods - Array(options[:only]).map(&:to_s)
        elsif options[:except]
          Array(options[:except]).map(&:to_s) & instance_methods
        else
          []
        end
      end
    end
  end
end
