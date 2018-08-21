class DelayedJobFailure < ApplicationRecord
  def self.per_page; 25 end

  scope :unread, -> { where(:read => false) }
  serialize :backtrace
end
