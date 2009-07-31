class Instance < ActiveRecord::Base
  belongs_to :app
  validates_presence_of :app
end
