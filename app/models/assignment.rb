class Assignment < ActiveRecord::Base
  belongs_to :service
  belongs_to :host
  validates_presence_of :service
  validates_presence_of :host
end