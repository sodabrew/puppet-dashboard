require 'timeline_fu/matchers'
require 'timeline_fu/macros'

module ActiveSupport
  class TestCase
    include TimelineFu::Matchers
    if ! defined? Spec
      extend TimelineFu::Macros
    end
  end
end
