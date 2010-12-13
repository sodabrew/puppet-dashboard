class Report < ActiveRecord::Base
  def self.per_page; 20 end # Pagination
  belongs_to :node

  has_many :logs, :class_name => "ReportLog", :dependent => :destroy
  has_many :resource_statuses, :dependent => :destroy
  has_many :metrics, :dependent => :destroy
  has_many :events, :through => :resource_statuses

  before_validation :assign_to_node
  validates_presence_of :host
  validates_presence_of :time
  validates_uniqueness_of :host, :scope => :time, :allow_nil => true
  after_save :update_node
  after_destroy :replace_last_report

  default_scope :order => 'time DESC'

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

  def failed_resources?
    failed_resources > 0 or metrics.empty?
  end

  def changed_resources?
    changed_resources > 0
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
    comparison_report.resource_statuses.each do |resource_status|
      resource_type = resource_status.resource_type
      title = resource_status.title
      name = resource_status.name
      my_properties = events_to_hash( self.resource_statuses.find_by_resource_type_and_title(resource_type, title).events )
      their_properties = events_to_hash( resource_status.events )
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

  def self.create_from_yaml(report_yaml)
    ActiveRecord::Base.transaction do
      raw_report = YAML.load(report_yaml)

      unless raw_report.is_a? Puppet::Transaction::Report
        raise ArgumentError, "The supplied report is in invalid format '#{raw_report.class}', expected 'Puppet::Transaction::Report'"
      end

      raw_report.extend(ReportExtensions)

      report = Report.create!(
        :time => raw_report.time,
        :host => raw_report.host,
        :kind => raw_report.kind
      )

      total_time = nil
      raw_report.metrics.each do |metric_category, metrics|
        metrics.values.each do |name, _, value|
          total_time = value if metric_category.to_s == "time" and name.to_s == "total"
          report.metrics.create!(
            :category  => metric_category.to_s,
            :name      => name.to_s,
            :value     => value
          )
        end
      end
      unless total_time
        time_metrics = raw_report.metric_value(:time)
        if time_metrics
          total_time = time_metrics.values.sum(&:last) 
          report.metrics.create!(
            :category => "time",
            :name     => "total",
            :value    => total_time
          )
        end
      end

      raw_report.resource_statuses.each do |resource,status|
        resource =~ /^(.+?)\[(.+)\]$/
        resource_type, title = $1, $2
        resource_status = report.resource_statuses.create!(
          :resource_type      => resource_type,
          :title              => title,
          :evaluation_time    => status.evaluation_time,
          :file               => status.file,
          :line               => status.line,
          :source_description => status.source_description,
          :tags               => status.tags,
          :time               => status.time,
          :change_count       => status.change_count || 0,
          :out_of_sync        => status.out_of_sync
        )
        status.events.each do |event|
          resource_status.events.create!(
            :property           => event.property,
            :previous_value     => event.previous_value,
            :desired_value      => event.desired_value,
            :message            => event.message,
            :name               => event.name.to_s,
            :source_description => event.source_description,
            :status             => event.status,
            :tags               => event.tags,
            :time               => event.time
          )
        end
      end

      raw_report.logs.each do |log|
        report.logs.create!(
          :level   => log.level.to_s,
          :message => log.message,
          :source  => log.source,
          :tags    => log.tags,
          :time    => log.time,
          :file    => log.file,
          :line    => log.line
        )
      end

      report.status = report.failed_resources? ? 'failed' : report.changed_resources? ? 'changed' : 'unchanged'
      report.save!
      report.update_node(true)
      report
    end
  end

  def assign_to_node
    self.node = Node.find_or_create_by_name(self.host)
  end

  def update_node(force=false)
    if node && (force || (node.reported_at.nil? || (node.reported_at-1.second) <= self.time))
      node.assign_last_report(self, force)
    end
  end

  private

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
