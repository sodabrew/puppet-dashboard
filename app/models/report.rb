require 'puppet'
class Report < ActiveRecord::Base
  belongs_to :node

  before_create :assign_to_node

  delegate :time, :logs, :host, :to => :parsed

  default_scope :order => 'created_at DESC'

  def status
    return 'failed' if metrics[:resources][:failed] > 0
    return 'failed' if metrics[:resources][:failed_restarts] > 0
    'success'
  end

  def metrics
    @metrics ||= parsed.metrics.with_indifferent_access
  end

  def parsed
    raise "No report data for #{self.inspect}, unable to parse" unless report
    @parsed ||= YAML.load(report)
  end

  private

  def assign_to_node
    self.node = Node.find_or_create_by_name(host)
    node.update_attribute(:reported_at, Time.now)
  end
end
