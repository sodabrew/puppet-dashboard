class Parameter < ActiveRecord::Base
  belongs_to :parameterable, :polymorphic => true
  validates_presence_of :key

  serialize :value

  fires :added_to,      :on => :create,   :secondary_subject => 'parameterable'
  fires :removed_from,  :on => :destroy,  :secondary_subject => 'parameterable'
  fires :updated_on,    :on => :update,   :secondary_subject => 'parameterable'

  def name
    "parameter #{key}"
  end
end
