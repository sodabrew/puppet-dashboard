require 'puppet'
require 'pp'
class ReportsController < InheritedResources::Base
  layout 'application'
  protect_from_forgery :except => :create
end
