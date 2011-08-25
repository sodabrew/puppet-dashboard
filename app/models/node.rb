require 'puppet_https'

class Node < ActiveRecord::Base
  def self.per_page; 20 end # Pagination

  include NodeGroupGraph
  extend FindFromForm

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships, :dependent => :destroy
  has_many :node_classes, :through => :node_class_memberships
  has_many :node_group_memberships, :dependent => :destroy
  has_many :node_groups, :through => :node_group_memberships
  has_many :reports, :dependent => :destroy
  has_many :resource_statuses, :through => :reports

  belongs_to :last_apply_report, :class_name => 'Report'
  belongs_to :last_inspect_report, :class_name => 'Report'

  def self.possible_derived_statuses
    self.possible_statuses.unshift("unresponsive")
  end

  def self.possible_statuses
    ["failed", "pending", "changed", "unchanged"]
  end

  named_scope :with_last_report, :include => :last_apply_report
  named_scope :by_report_date, :order => 'reported_at DESC'

  named_scope :search, lambda{|q| q.blank? ? {} : {:conditions => ['name LIKE ?', "%#{q}%"]} }

  named_scope :by_latest_report, proc { |order|
    direction = {1 => 'ASC', 0 => 'DESC'}[order]
    direction ? {:order => "reported_at #{direction}"} : {}
  }

  has_parameters

  fires :created, :on => :create
  fires :updated, :on => :update
  fires :removed, :on => :destroy

  named_scope :unresponsive, lambda {{
    :conditions => [
      "last_apply_report_id IS NOT NULL AND reported_at < ?",
      SETTINGS.no_longer_reporting_cutoff.seconds.ago
    ]
  }}

  possible_statuses.each do |node_status|
    named_scope node_status, lambda {{
      :conditions => [
        "last_apply_report_id IS NOT NULL AND reported_at >= ? AND nodes.status = '#{node_status}'",
        SETTINGS.no_longer_reporting_cutoff.seconds.ago
      ]
    }}
  end

  named_scope :unreported, :conditions => {:reported_at => nil}

  named_scope :hidden, :conditions => {:hidden => true}

  named_scope :unhidden, :conditions => {:hidden => false}

  def self.find_by_id_or_name!(identifier)
    find_by_id(identifier) or find_by_name!(identifier)
  end

  def self.find_from_inventory_search(search_params)
    queries = search_params.map do |param|
      fact  = CGI::escape(param['fact'])
      value = CGI::escape(param['value'])
      "facts.#{ fact }.#{ param['comparator'] }=#{ value }"
    end

    url = "https://#{SETTINGS.inventory_server}:#{SETTINGS.inventory_port}/" +
          "production/facts_search/search?#{ queries.join('&') }"

    matches = JSON.parse(PuppetHttps.get(url, 'pson'))
    nodes = Node.find_all_by_name(matches)
    found = nodes.map(&:name).map(&:downcase)
    matched_nodes = matches.map do |m|
      Node.create!(:name => m) unless found.include? m.downcase
    end

    return nodes + matched_nodes.compact
  end

  def configuration
    {
      'name'       => name,
      'classes'    => all_node_classes.collect(&:name),
      'parameters' => parameter_list
    }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end

  def resource_count
    last_apply_report.resource_statuses.count rescue nil
  end

  def pending_count
    last_apply_report.resource_statuses.pending(true).failed(false).count rescue nil
  end

  def failed_count
    last_apply_report.resource_statuses.failed(true).count rescue nil
  end

  def compliant_count
    last_apply_report.resource_statuses.pending(false).failed(false).count rescue nil
  end

  def self.to_csv_header
    CSV.generate_line(Node.to_csv_properties + ResourceStatus.to_csv_properties)
  end

  def self.to_csv_properties
    [:name, :status, :resource_count, :pending_count, :failed_count, :compliant_count]
  end

  def to_csv
    node_segment = self.to_csv_array
    rows = []
    if (last_apply_report.resource_statuses.present? rescue false)
      last_apply_report.resource_statuses.each do |res|
        rows << node_segment + res.to_csv_array
      end
    else
      rows << node_segment + ([nil] * ResourceStatus.to_csv_properties.length)
    end

    rows.map do |row|
      CSV.generate_line row
    end.join("\n")
  end

  def timeline_events
    TimelineEvent.for_node(self)
  end

  # Placeholder attributes

  def environment
    'production'
  end

  attr_accessor :node_class_names
  attr_accessor :node_class_ids
  before_validation :assign_node_classes
  def assign_node_classes
    return true unless @node_class_ids || @node_class_names
    raise NodeClassificationDisabledError.new unless SETTINGS.use_external_node_classification
    node_classes = []
    node_classes << NodeClass.find_from_form_names(*@node_class_names) if @node_class_names
    node_classes << NodeClass.find_from_form_ids(*@node_class_ids)     if @node_class_ids

    self.node_classes = node_classes.flatten.uniq
  rescue ActiveRecord::RecordInvalid => e
    self.errors.add_to_base(e.message)
    return false
  end

  attr_accessor :node_group_names
  attr_accessor :node_group_ids
  before_validation :assign_node_groups
  def assign_node_groups
    return true unless @node_group_ids || @node_group_names
    node_groups = []
    node_groups << NodeGroup.find_from_form_names(*@node_group_names) if @node_group_names
    node_groups << NodeGroup.find_from_form_ids(*@node_group_ids)     if @node_group_ids

    self.node_groups = node_groups.flatten.uniq
  rescue ActiveRecord::RecordInvalid => e
    self.errors.add_to_base(e.message)
    return false
  end

  def assign_last_apply_report_if_newer(report)
    raise "wrong report type" unless report.kind == "apply"

    if reported_at.nil? or reported_at.to_i < report.time.to_i
      self.last_apply_report = report
      self.reported_at = report.time
      self.status = report.status
      self.save!
    end
  end

  def assign_last_inspect_report_if_newer(report)
    raise "wrong report type" unless report.kind == "inspect"

    if ! self.last_inspect_report or self.last_inspect_report.time.to_i < report.time.to_i
      self.last_inspect_report = report
      self.save!
    end
  end

  def find_and_assign_last_apply_report
    report = self.reports.applies.first
    if report
      self.reported_at = nil
      assign_last_apply_report_if_newer(report)
    else
      self.last_apply_report = nil
      self.reported_at = nil
      self.status = nil
      self.save!
    end
  end

  def find_and_assign_last_inspect_report
    report = self.reports.inspections.first
    self.last_inspect_report = nil
    if report
      assign_last_inspect_report_if_newer(report)
    else
      self.save!
    end
  end

  def facts
    return @facts if @facts
    url = "https://#{SETTINGS.inventory_server}:#{SETTINGS.inventory_port}/" +
          "production/facts/#{CGI.escape(self.name)}"
    data = JSON.parse(PuppetHttps.get(url, 'pson'))
    if data['timestamp']
      timestamp = Time.parse data['timestamp']
    elsif data['values']['--- !ruby/sym _timestamp']
      timestamp = Time.parse(data['values'].delete('--- !ruby/sym _timestamp'))
    else
      timestamp = nil
    end
    @facts = {
      :timestamp => timestamp,
      :values => data['values']
    }
  end

  def self.resource_status_totals(resource_status, scope='all')
    scope ||="all"
    raise ArgumentError, "No such status #{resource_status}" unless possible_statuses.unshift("total").include?(resource_status)
    options = {:conditions => "metrics.category = 'resources' AND metrics.name = '#{resource_status}'", :joins => 'left join metrics on metrics.report_id = nodes.last_apply_report_id'}
    ['all', 'index'].include?(scope) ? Node.sum(:value, options).to_i : Node.send(scope).sum(:value, options).to_i
  end
end
