require 'ardes/response_for'
ActionController::Base.send :include, Ardes::ResponseFor

if Rails.version < "2.3.0"
  require 'ardes/response_for/bc'
  ActionController::Base.send :include, Ardes::ResponseFor::Bc
end