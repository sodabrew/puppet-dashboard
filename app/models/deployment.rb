class Deployment < ActiveRecord::Base
  belongs_to :instance
  belongs_to :host
  validates_presence_of :instance
  validates_presence_of :host
end
