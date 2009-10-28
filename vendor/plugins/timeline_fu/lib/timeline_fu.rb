require 'timeline_fu/fires'

module TimelineFu  
end

ActiveRecord::Base.send :include, TimelineFu::Fires
