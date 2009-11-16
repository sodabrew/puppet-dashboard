class TimelineEvent < ActiveRecord::Base
  belongs_to :actor,              :polymorphic => true
  belongs_to :subject,            :polymorphic => true
  belongs_to :secondary_subject,  :polymorphic => true

  def self.recent(limit = 10)
    all(:order => 'created_at DESC', :limit => limit)
  end

  def subject_name
    subject ? subject.name : "A #{subject_type.downcase}"
  end

  def secondary_name
    secondary_subject ? secondary_subject.name : "A #{secondary_subject_type.downcase}"
  end
end
