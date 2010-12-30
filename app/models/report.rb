class Report < ActiveRecord::Base
  def self.per_page; 20 end # Pagination
  belongs_to :node

  has_many :logs, :class_name => "ReportLog", :dependent => :destroy
  has_many :resource_statuses, :dependent => :destroy
  has_many :metrics, :dependent => :destroy
  has_many :events, :through => :resource_statuses

  accepts_nested_attributes_for :metrics, :resource_statuses, :logs

  before_validation :assign_to_node
  validates_presence_of :host
  validates_presence_of :time
  validates_uniqueness_of :host, :scope => :time, :allow_nil => true
  after_save :update_node
  after_destroy :replace_last_report

  default_scope :order => 'time DESC'

  named_scope :inspections, :conditions => {:kind => "inspect"}
  named_scope :applies,     :conditions => {:kind => "apply"  }
  named_scope :baselines,   :include => :node, :conditions => ['nodes.baseline_report_id = reports.id']

  def self.find_last_for(node)
    self.first(:conditions => {:node_id => node.id}, :order => 'time DESC', :limit => 1)
  end

  def total_resources
    metric_value("resources", "total")
  end

  def failed_resources
    metric_value("resources", "failed")
  end

  def failed_restarts
    metric_value("resources", "failed_restarts")
  end

  def skipped_resources
    metric_value("resources", "skipped_resources")
  end

  def changed_resources
    metric_value("changes", "total")
  end

  TOTAL_TIME_FORMAT = "%0.2f"

  def total_time
    TOTAL_TIME_FORMAT % metric_value("time", "total")
  end

  def config_retrieval_time
    TOTAL_TIME_FORMAT % metric_value("time", "config_retrieval")
  end

  def metric_value(category, name)
    metric = metrics.find_by_category_and_name(category, name)
    (metric and metric.value) or 0
  end

  def diff(comparison_report)
    diff_stuff = {}
    comparison_resources = resources_to_hash(comparison_report.resource_statuses)
    our_resources = resources_to_hash(resource_statuses)
    (comparison_resources.keys | our_resources.keys).each do |resource_name|
      comparison_resource = comparison_resources[resource_name] || {}
      our_resource = our_resources[resource_name] || {}
      (comparison_resource.keys | our_resource.keys).each do |property|
        if our_resource[property] != comparison_resource[property]
          diff_stuff[resource_name] ||= {}
          diff_stuff[resource_name][property.to_sym] = [ our_resource[property], comparison_resource[property] ]
        end
      end
    end
    diff_stuff
  end

  def resources
    self.report.resource_statuses.keys
  end

  def self.attribute_hash_from(report_hash)
    attribute_hash = report_hash.dup
    attribute_hash["logs_attributes"] = attribute_hash.delete("logs")
    attribute_hash["resource_statuses_attributes"] = attribute_hash.delete("resource_statuses")
    attribute_hash["metrics_attributes"] = attribute_hash.delete("metrics")
    attribute_hash["resource_statuses_attributes"].each do |resource_status_hash|
      resource_status_hash["events_attributes"] = resource_status_hash.delete("events") || {}
    end
    attribute_hash["metrics_attributes"] = attribute_hash["metrics_attributes"].map do |category,metric_hash|
      metric_hash.map do |name,value|
        {:category => category, :name => name, :value => value}
      end
    end.flatten
    attribute_hash
  end

  def self.create_from_yaml(report_yaml)
      raw_report = YAML.load(report_yaml)

      unless raw_report.is_a? Puppet::Transaction::Report
        raise ArgumentError, "The supplied report is in invalid format '#{raw_report.class}', expected 'Puppet::Transaction::Report'"
      end

      raw_report.extend(ReportExtensions)
      report_hash = ReportTransformer.apply(raw_report.to_hash)

      Report.create!(Report.attribute_hash_from(report_hash))
  end

  def assign_to_node
    self.node = Node.find_or_create_by_name(self.host)
  end

  def update_node
    if node && (node.reported_at.nil? || (node.reported_at-1.second) <= self.time)
      node.assign_last_report(self)
    end
  end

  def baseline?
    self.node.baseline_report == self
  end

  def baseline!
    self.node.baseline_report = self
    self.node.save!
  end

  private

  def resources_to_hash(resources)
    hash = {}
    resources.each do |resource_status|
      hash[resource_status.name] = events_to_hash(resource_status.events)
    end
    hash
  end

  def events_to_hash(events)
    events.inject({}) do |hash, event|
      hash[event.property] = event.previous_value
      hash
    end
  end

  def replace_last_report
    node.assign_last_report if node
  end
end
