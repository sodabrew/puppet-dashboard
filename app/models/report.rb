require 'puppet'
class Report < ActiveRecord::Base
  belongs_to :node

  before_create :assign_to_node

  delegate :time, :metrics, :logs, :host, :to => :parsed

  def status
    return 'failed' if parsed.metrics["resources"][:failed] > 0
    return 'failed' if parsed.metrics["resources"][:failed_restarts] > 0
    'success'
  end

  def parsed
    @parsed ||= YAML.load(report)
  end

  private

  def assign_to_node
    node = Node.find_by_name(parsed.host)
    write_attribute(:node_id, node.id) if node
  end
end
