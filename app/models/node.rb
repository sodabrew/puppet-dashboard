require 'puppet_https'

class Node < ActiveRecord::Base
  def self.per_page; 20 end # Pagination

  include NodeGroupGraph

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_class_memberships, :dependent => :destroy
  has_many :node_classes, :through => :node_class_memberships
  has_many :node_group_memberships, :dependent => :destroy
  has_many :node_groups, :through => :node_group_memberships

  has_many :reports, :dependent => :destroy
  belongs_to :last_apply_report, :class_name => 'Report'
  belongs_to :last_inspect_report, :class_name => 'Report'

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

  # Return nodes based on their currentness and successfulness.
  #
  # The terms are:
  # * currentness: +true+ uses the latest report (current) and +false+ uses any report.
  # * successfulness: +true+ means a successful report, +false+ a failing report.
  #
  # Thus:
  # * current and successful: Return only nodes that are currently successful.
  # * current and failing: Return only nodes that are currently failing.
  # * non-current and successful: Return any nodes that ever had a successful report.
  # * non-current and failing: Return any nodes that ever had a failing report.
  named_scope :by_currentness_and_successfulness, lambda {|currentness, successfulness|
    operator = successfulness ? '!=' : '='
    if currentness
      { :conditions => ["nodes.status #{operator} 'failed' AND nodes.last_apply_report_id is not NULL"]  }
    else
      {
        :conditions => ["reports.kind = 'apply' AND reports.status #{operator} 'failed'"],
        :joins => :reports,
        :group => 'nodes.id',
      }
    end
  }

  named_scope :reported, :conditions => ["reported_at IS NOT NULL"]

  # Return nodes that have never reported.
  named_scope :unreported, :conditions => {:reported_at => nil}

  # Return nodes that haven't reported recently.
  named_scope :no_longer_reporting, lambda{{:conditions => ['reported_at < ?', SETTINGS.no_longer_reporting_cutoff.seconds.ago] }}

  named_scope :hidden, :conditions => {:hidden => true}

  named_scope :unhidden, :conditions => {:hidden => false}

  def self.label_for_currentness_and_successfulness(currentness, successfulness)
    return "#{currentness ? 'Currently' : 'Ever'} #{successfulness ? (currentness ? 'successful' : 'succeeded') : (currentness ? 'failing' : 'failed')}"
  end

  def self.find_from_inventory_search(search_params)
    query_string = search_params.
      map {|param| "facts.#{CGI::escape param["fact"]}.#{param["comparator"]}=#{CGI::escape param["value"]}" }.
      join("&")

    url = "https://#{SETTINGS.inventory_server}:#{SETTINGS.inventory_port}/production/inventory/search?#{query_string}"
    matches = JSON.parse(PuppetHttps.get(url, 'pson'))
    nodes = Node.find_all_by_name(matches)
    found = nodes.map(&:name).map(&:downcase)
    nodes.concat matches.reject {|match| found.include? match.downcase}.map {|match| Node.create!(:name => match)}
  end

  def configuration
    { 'name' => name, 'classes' => all_node_classes.collect(&:name), 'parameters' => parameter_list }
  end

  def to_yaml(opts={})
    configuration.to_yaml(opts)
  end

  def timeline_events
    TimelineEvent.for_node(self)
  end

  # Placeholder attributes

  def environment
    'production'
  end

  def status_class
    return 'no reports' unless last_apply_report
    last_apply_report.status
  end

  attr_accessor :node_class_names
  attr_accessor :node_class_ids
  before_validation :assign_node_classes
  def assign_node_classes
    return true unless @node_class_ids || @node_class_names
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
    pson_data = PuppetHttps.get("https://#{SETTINGS.inventory_server}:#{SETTINGS.inventory_port}/production/facts/#{CGI.escape(self.name)}", 'pson')
    data = JSON.parse(pson_data)
    @facts = { :timestamp => Time.parse(data['timestamp']),
      :values => data['values']
    }
  end
end
