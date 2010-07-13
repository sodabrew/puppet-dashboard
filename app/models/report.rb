require "#{RAILS_ROOT}/lib/puppet/report"

class Report < ActiveRecord::Base
  def self.per_page; 20 end # Pagination

  belongs_to :node

  validates_presence_of :host
  validates_presence_of :time
  validates_uniqueness_of :host, :scope => :time, :allow_nil => true
  before_validation :process_report

  delegate :logs, :to => :report

  default_scope :order => 'time DESC'

  serialize :report, Puppet::Transaction::Report

  def succeeded?
    failed_resources == 0
  end

  def status
    success? ? 'success' : 'failure'
  end

  def metrics
    return unless report && report.metrics
    @metrics ||= report.metrics.with_indifferent_access
  end

  TOTAL_TIME_FORMAT = "%0.2f"

  def total_time
    metrics && metrics[:time] && TOTAL_TIME_FORMAT % metrics[:time][:total]
  end

  def total_resources
    metrics && metrics[:resources] && metrics[:resources][:total]
  end

  def failed_resources
    metrics && metrics[:resources] && metrics[:resources][:failed]
  end

  private

  def process_report
    set_attributes
    assign_to_node
    set_node_reported_at
    return true
  end

  def set_attributes
    self.success = succeeded?
    self.time    = report.time
    self.host    = report.host
  end

  def assign_to_node
    self.node = Node.find_or_create_by_name(report.host)
  end

  def set_node_reported_at
    node.reported_at = report.time
    node.send :update_without_callbacks # do not create a timeline event
  end
end
