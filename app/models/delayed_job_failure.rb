class DelayedJobFailure < ActiveRecord::Base
  def self.per_page; 25 end

  scope :unread, where(:read => false)
  serialize :backtrace

  attr_accessible :summary, :backtrace, :details, :read, :created_at, :updated_at
end
