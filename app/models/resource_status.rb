class ResourceStatus < ApplicationRecord
  belongs_to :report, -> { includes(:node) }, optional: true
  has_many :events, :class_name => 'ResourceEvent', :dependent => :delete_all

  accepts_nested_attributes_for :events

  serialize :tags, Array

  scope :inspections, -> { joins(:report).where("reports.kind = 'inspect'") }

  scope :latest_inspections, lambda {
    includes(:report => :node).where(<<-SQL).references(:nodes)
      nodes.last_inspect_report_id = resource_statuses.report_id
    SQL
  }

  scope :by_file_content, lambda {|content|
    includes(:events).where(<<-SQL, "{md5}#{content}").references(:resource_events)
      resource_statuses.resource_type = 'File' AND
      resource_events.property = 'content' AND
      resource_events.previous_value = ?
    SQL
  }

  scope :without_file_content, lambda {|content|
    includes(:events).where(<<-SQL, "{md5}#{content}").references(:resource_events)
      resource_statuses.resource_type = 'File' AND
      resource_events.property = 'content' AND
      resource_events.previous_value != ?
    SQL
  }

  scope :by_file_title, lambda {|title|
    includes(:events).where(<<-SQL, title)
      resource_statuses.resource_type = 'File' AND
      resource_statuses.title = ?
    SQL
  }

  scope :pending, lambda { |predicate|
    predicate = predicate ? '' : 'NOT'
    where(<<-SQL).references(:resource_events)
        resource_statuses.id #{predicate} IN (
          SELECT resource_statuses.id FROM resource_statuses
            INNER JOIN resource_events ON resource_statuses.id = resource_events.resource_status_id
            WHERE resource_events.status = 'noop'
        )
    SQL
  }

  scope :failed, lambda { |predicate| where(:failed => predicate) }

  def self.to_csv_properties
    [:resource_type, :title, :evaluation_time, :file, :line, :time, :change_count, :out_of_sync_count, :skipped, :failed]
  end

  def name
    "#{resource_type}[#{title}]"
  end
end
