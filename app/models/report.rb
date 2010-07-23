class Report < ActiveRecord::Base
  def self.per_page; 20 end # Pagination

  belongs_to :node

  validate :report_contains_metrics
  validates_presence_of :host
  validates_presence_of :time
  validates_uniqueness_of :host, :scope => :time, :allow_nil => true
  before_validation :process_report

  delegate :logs, :metric_value, :to => :report
  delegate :total_resources, :failed_resources, :failed_restarts, :skipped_resources,
           :changed_resources, :failed?, :changed?,
           :to => :report

  default_scope :order => 'time DESC'

  serialize :report, Puppet::Transaction::Report

  def report
    rep = read_attribute(:report)
    rep.extend(ReportExtensions) unless rep.nil? or rep.is_a?(ReportExtensions)
    rep
  end

  def status
    failed? ? 'failure' : 'success'
  end

  def metrics
    return unless report && report.metrics
    @metrics ||= report.metrics.with_indifferent_access
  end

  TOTAL_TIME_FORMAT = "%0.2f"

  def total_time
    if value = report.total_time
      TOTAL_TIME_FORMAT % value
    end
  end

  def config_retrieval_time
    if value = metric_value(:time, :config_retrieval)
      TOTAL_TIME_FORMAT % value
    end
  end

  private

  def process_report
    set_attributes
    assign_to_node
    set_node_reported_at
    return true
  end

  def set_attributes
    self.success = !report.failed?
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

  def report_contains_metrics
    not report.metrics.nil?
  end
end
