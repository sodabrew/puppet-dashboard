class Parameter < ActiveRecord::Base
  belongs_to :parameterable, :polymorphic => true
  validates_presence_of :key

  serialize :value
end
