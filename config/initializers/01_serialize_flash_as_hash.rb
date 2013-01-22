# This is a backport of the patch: https://github.com/rails/rails/commit/36376560fdd02f955ae3bf6b7792b784443660ad
# it allows other applications to unmarshal the session cookie without needing the full rails stack.
#
# Without this, applications that co-exist with puppet-aashboard (such as certificate service or live management)
# will invalidate the session.
module ActionController::Flash
  class FlashHash
    def self.from_session_value(value)
      flash = case value
              when FlashHash
                new(::Hash[value], value.instance_variable_get(:@used))
              when ::Hash
                new(value['flash'], value['used'])
              else
                new
              end
      flash.sweep
      flash
    end

    def to_session_value
      return nil if empty?
      {'flash' => ::Hash[self], 'used' => @used}
    end

    def initialize(flash = {}, used = {}) #:nodoc:
      @used = {}
      flash.each { |k,v| self[k] = v }
      @used = used
    end

    def store(session, key = "flash")
      return if self.empty?
      session[key] = self.to_session_value
    end
  end

  module InstanceMethods
    def flash #:doc:
      if !defined?(@_flash)
        @_flash = FlashHash.from_session_value(session['flash'])
        @_flash.sweep
      end

      @_flash
    end
  end
end
