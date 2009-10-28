module TimelineFu
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def fires(event_type, opts)
        raise ArgumentError, "Argument :on is mandatory" unless opts.has_key?(:on)

        # Array provided, set multiple callbacks
        if opts[:on].kind_of?(Array)
          opts[:on].each { |on| fires(event_type, opts.merge({:on => on})) }
          return
        end

        opts[:subject] = :self unless opts.has_key?(:subject)

        method_name = :"fire_#{event_type}_after_#{opts[:on]}"
        define_method(method_name) do
          create_options = [:actor, :subject, :secondary_subject].inject({}) do |memo, sym|
            case opts[sym]
            when :self
              memo[sym] = self
            else
              memo[sym] = send(opts[sym]) if opts[sym]
            end
            memo
          end
          create_options[:event_type] = event_type.to_s

          TimelineEvent.create!(create_options)
        end

        send(:"after_#{opts[:on]}", method_name, :if => opts[:if])
      end
    end
  end
end
