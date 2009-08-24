class Assignment < ActiveRecord::Base
  belongs_to :service
  belongs_to :node
  validates_presence_of :service
  validates_presence_of :node
end