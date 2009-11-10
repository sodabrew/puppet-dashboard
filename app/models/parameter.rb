class Parameter < ActiveRecord::Base
  belongs_to :parameterable, :polymorphic => true
  validates_presence_of :key

  serialize :value

  fires :added_to,      :on => :create,   :subject => :parameterable
  fires :removed_from,  :on => :destroy,  :subject => :parameterable
  fires :updated_on,    :on => :update,   :subject => :parameterable
end
