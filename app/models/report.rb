require 'puppet'
class Report < ActiveRecord::Base
  belongs_to :node

  before_create :process_report

  delegate :time, :logs, :host, :to => :parsed

  default_scope :order => 'created_at DESC'

  def succeeded?
    metrics[:resources][:failed] == 0
  end

  def status
    succeeded? ? 'success' : 'failed'
  end

  def metrics
    @metrics ||= parsed.metrics.with_indifferent_access
  end

  def parsed
    raise "No report data for #{self.inspect}, unable to parse" unless report
    @parsed ||= YAML.load(report)
  end

  private

  def process_report
    assign_to_node
    set_node_reported_at
    set_success_status
  end

  def assign_to_node
    self.node = Node.find_or_create_by_name(host)
  end

  def set_success_status
    self.success = success?
  end

  def set_node_reported_at
    node.update_attribute(:reported_at, Time.now)
  end
end
