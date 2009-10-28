module TimelineFu
  module Matchers
    class FireEvent
      def initialize(event_type, opts = {})
        @event_type = event_type
        @opts = opts
        @method = :"fire_#{@event_type}_after_#{@opts[:on]}"
      end

      def matches?(subject)
        @subject = subject

        defines_callback_method? && setups_up_callback?
      end

      def defines_callback_method?
        if @subject.instance_methods.include?(@method.to_s)
          true
        else
          @missing = "#{@subject.name} does not respond to #{@method}"
          false
        end
      end

      def setups_up_callback?
        callback_chain_name = "after_#{@opts[:on]}_callback_chain"
        callback_chain = @subject.send(callback_chain_name)
        if callback_chain.any? {|chain| chain.method == @method }
          true
        else
          @missing = "does setup after #{@opts[:on]} callback for #{@method}"
          false
        end
      end

      def description
        "fire a #{@event_type} event"
      end

      def expectation
        expected = "#{@subject.name} to #{description}"
      end

      def failure_message
        "Expected #{expectation} (#{@missing})"
      end

      def negative_failure_message
        "Did not expect #{expectation}"
      end

    end

    def fire_event(event_type, opts)
      FireEvent.new(event_type, opts)
    end
  end
end
