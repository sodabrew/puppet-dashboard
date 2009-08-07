module Ardes#:nodoc:
  # Extension to facilitate writing responses in mixins
  #
  # extend this into your own module to have it act as a response_for namespace
  # when this module is included into a controller, the responses will be copied
  # over, along with the actions.
  #
  # NOTE: If you are defining self.included on your module, make sure you put the
  # extend Ardes::ResponsesModule *after* self.included method definition.
  #
  # Example:
  #
  #  module MyActions
  #    extend Ardes::ResponsesModule
  #
  #    def foo
  #      do_foo
  #    end
  #
  #    response_for :foo do |format|
  #      format.html { # do a response }
  #    end
  #  end
  #
  #  class AController < ApplicationController
  #    include MyActions
  #    # now this controller has foo and response_for :foo
  #  end
  module ResponsesModule
    include ResponseFor::ClassMethods
    
    def self.extended(mixin)
      class << mixin
        def included_with_responses(controller_class)
          controller_class.include_responses_from(self)
          included_without_responses(controller_class)
        end
        alias_method_chain :included, :responses
      end
    end
  end
end