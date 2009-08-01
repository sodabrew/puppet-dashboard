class Instance < ActiveRecord::Base
  belongs_to :app
  belongs_to :service
  validates_presence_of :app
end
