require 'puppet'
class Report < ActiveRecord::Base
  belongs_to :node

  validates_presence_of :host
  validates_presence_of :time
  validates_uniqueness_of :host, :scope => :time, :allow_nil => true
  before_validation :process_report

  delegate :logs, :to => :report

  default_scope :order => 'time DESC'

  serialize :report

  def succeeded?
    metrics[:resources] && metrics[:resources][:failed] == 0
  end

  def status
    succeeded? ? 'success' : 'failed'
  end

  def metrics
    @metrics ||= report.metrics.with_indifferent_access
  end

  private

  def process_report
    set_attributes
    assign_to_node
    set_node_reported_at
    return true
  end

  def assign_to_node
    self.node = Node.find_or_create_by_name(host)
  end

  def set_attributes
    set_success
    set_time_and_host
  end

  def set_success
    self.success = succeeded?
  end

  def set_time_and_host
    self.time = report.time
    self.host = report.host
  end

  def set_node_reported_at
    node.update_attribute(:reported_at, report.time)
  end
end
