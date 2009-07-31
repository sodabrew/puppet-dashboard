class Service < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :apps
  has_many :source_edges, :class_name => 'Edge', :foreign_key => 'source_id'
  has_many :target_edges, :class_name => 'Edge', :foreign_key => 'target_id'
end
