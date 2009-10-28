class TimelineEvent < ActiveRecord::Base
  belongs_to :actor,              :polymorphic => true
  belongs_to :subject,            :polymorphic => true
  belongs_to :secondary_subject,  :polymorphic => true

  def self.recent(limit = 20)
    all(:order => 'created_at DESC', :limit => limit)
  end
end
