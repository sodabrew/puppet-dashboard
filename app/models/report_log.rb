class ReportLog < ApplicationRecord
  belongs_to :report

  serialize :tags, Array
end
