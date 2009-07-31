class Deployment < ActiveRecord::Base
  belongs_to :app
  belongs_to :host
  validates_presence_of :app
  validates_presence_of :host
end
