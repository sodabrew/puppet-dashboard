class Edge < ActiveRecord::Base
  belongs_to :source, :class_name => 'Service'
  belongs_to :target, :class_name => 'Service'

  validates_presence_of :source
  validates_presence_of :target
end
