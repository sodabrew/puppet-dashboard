class ResourceStatus < ActiveRecord::Base
  belongs_to :report
  has_many :events, :class_name => "ResourceEvent", :dependent => :destroy

  accepts_nested_attributes_for :events

  serialize :tags, Array

  named_scope :inspections, { :joins => :report, :conditions => "reports.kind = 'inspect'" }

  named_scope :by_file_content, lambda {|content|
    {
      :conditions => ["resource_statuses.resource_type = 'File' AND resource_events.property = 'content' AND resource_events.previous_value = ?", "{md5}#{content}"],
      :joins => :events,
    }
  }

  named_scope :by_file_title, lambda {|title|
    {
      :conditions => ["resource_type = 'File' AND title = ?", title],
    }
  }

  def name
    "#{resource_type}[#{title}]"
  end
end
