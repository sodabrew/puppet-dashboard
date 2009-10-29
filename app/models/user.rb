class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field false
  end
end
