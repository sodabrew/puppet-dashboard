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
    if value = metric_value(:time, :total)
      TOTAL_TIME_FORMAT % value
    end
  end

  def config_retrieval_time
    if value = metric_value(:time, :config_retrieval)
      TOTAL_TIME_FORMAT % value
    end
  end

  def total_resources
    metric_value :resources, :total
  end

  def failed_resources
    metric_value :resources, :failed
  end

  def failed_restarts
    metric_value :resources, :failed_restarts
  end

  def skipped_resources
    metric_value :resources, :skipped_resources
  end

  def changes
    metric_value :changes, :total
  end

  # Returns the metric value at the key found by traversing the metrics hash
  # tree. Returns nil if any intermediary results are nil.
  #
  def metric_value(*keys)
    return nil unless metrics
    result = metrics
    keys.each do |key|
      result = result[key]
      break unless result
    end
    result
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
