class Metric < ActiveRecord::Base
  belongs_to :report
  attr_readonly :report_id
  attr_accessible :category, :name, :value
end
