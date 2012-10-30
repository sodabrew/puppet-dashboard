class ReportLog < ActiveRecord::Base
  belongs_to :report

  serialize :tags, Array

  attr_readonly :report_id
  attr_accessible :source, :level, :tags, :time, :message, :file, :line
end
