class App < ActiveRecord::Base
  belongs_to :customer
  validates_presence_of :name
  validates_presence_of :customer
end
