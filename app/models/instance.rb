class Instance < ActiveRecord::Base
  belongs_to :app
  belongs_to :service
  has_many   :deployments
  validates_presence_of :app
end
