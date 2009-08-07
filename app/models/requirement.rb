class Requirement < ActiveRecord::Base
  belongs_to :service
  belongs_to :instance
  
  validates_presence_of :service
  validates_presence_of :instance
end
