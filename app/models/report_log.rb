class ReportLog < ActiveRecord::Base
  belongs_to :report

  serialize :tags, Array
end
