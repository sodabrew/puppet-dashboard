module TimelineFu
  module Macros
    def should_fire_event(event_type, opts = {})
      should "fire #{event_type} on #{opts[:on]}" do
        matcher = fire_event(event_type, opts)

        assert_accepts matcher, self.class.name.gsub(/Test$/, '').constantize
      end
    end

    def should_not_fire_event(event_type, opts = {})
      should "fire #{event_type} on #{opts[:on]}" do
        matcher = fire_event(event_type, opts)

        assert_rejects matcher, self.class.name.gsub(/Test$/, '').constantize
      end
    end

  end
end
