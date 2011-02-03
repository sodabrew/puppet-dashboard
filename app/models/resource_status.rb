class ResourceStatus < ActiveRecord::Base
  belongs_to :report, :include => :node
  has_many :events, :class_name => "ResourceEvent", :dependent => :destroy

  accepts_nested_attributes_for :events

  serialize :tags, Array

  named_scope :inspections, { :joins => :report, :conditions => "reports.kind = 'inspect'" }

  named_scope :latest_inspections, {
    :conditions => "nodes.last_inspect_report_id = resource_statuses.report_id",
    :include    => [:report => :node],
  }

  named_scope :by_file_content, lambda {|content|
    {
      :conditions => ["resource_statuses.resource_type = 'File' AND resource_events.property = 'content' AND resource_events.previous_value = ?", "{md5}#{content}"],
      :include => :events,
    }
  }

  named_scope :without_file_content, lambda {|content|
    {
      :conditions => ["resource_statuses.resource_type = 'File' AND resource_events.property = 'content' AND resource_events.previous_value != ?", "{md5}#{content}"],
      :include => :events,
    }
  }

  named_scope :by_file_title, lambda {|title|
    {
      :conditions => ["resource_statuses.resource_type = 'File' AND resource_statuses.title = ?", title],
      :include => :events,
    }
  }

  def name
    "#{resource_type}[#{title}]"
  end
end
