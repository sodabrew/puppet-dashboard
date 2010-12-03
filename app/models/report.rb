class Report < ActiveRecord::Base
  def self.per_page; 20 end # Pagination
  belongs_to :node

  before_validation :ensure_valid_format
  before_validation :process_report
  validates_presence_of :host
  validates_presence_of :time
  validates_uniqueness_of :host, :scope => :time, :allow_nil => true
  after_save :update_node
  after_destroy :replace_last_report

  delegate :logs, :metric_value, :to => :report
  delegate :total_resources, :failed_resources, :failed_restarts, :skipped_resources,
           :changed_resources, :failed?, :changed?,
           :to => :report

  default_scope :order => 'time DESC'

  serialize :report, Puppet::Transaction::Report

  def self.find_last_for(node)
    self.first(:conditions => {:node_id => node.id}, :order => 'time DESC', :limit => 1)
  end

  def report
    rep = read_attribute(:report)
    rep.extend(ReportExtensions) unless rep.nil? or rep.is_a?(ReportExtensions)
    rep
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
    else
      TOTAL_TIME_FORMAT % 0
    end
  end

  def diff(comparison_report)
    diff_stuff = {}
    comparison_report.report.resource_statuses.each do |name, value|
      my_properties = events_to_hash( self.report.resource_statuses[name].events )
      their_properties = events_to_hash( value.events )
      my_properties.keys.each do |property|
        if my_properties[property] != their_properties[property]
          diff_stuff[name] ||= {}
          diff_stuff[name][property.to_sym] = [ my_properties[property], their_properties[property] ]
        end
      end
    end
    diff_stuff
  end

  def resources
    self.report.resource_statuses.keys
  end

  private

  def events_to_hash(events)
    events.inject({}) do |hash, event|
      hash[event.property] = event.previous_value
      hash
    end
  end

  def ensure_valid_format
    begin
      report
    rescue ActiveRecord::SerializationTypeMismatch
      errors.add_to_base("The report is in an invalid format")
      false
    end
  end

  def process_report
    set_attributes
    assign_to_node
    return true
  end

  def set_attributes
    self.status = failed? ? 'failed' : changed? ? 'changed' : 'unchanged'
    self.time   = report.time
    self.host   = report.host
  end

  def assign_to_node
    self.node = Node.find_or_create_by_name(report.host)
  end

  def update_node(force=false)
    if node && (force || (node.reported_at.nil? || (node.reported_at-1.second) <= self.time))
      node.assign_last_report(self)
    end
  end

  def replace_last_report
    node.assign_last_report if node
  end
end
