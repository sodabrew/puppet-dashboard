module ActiveModelScopes
  def self.included(base)
    base.scope :limit, lambda{|limit| {:limit => limit}}
    base.scope :where, lambda{|where| {:conditions => where}}
    base.scope :order, lambda{|order| {:order => order}}
  end
end

ActiveRecord::Base.send :include, ActiveModelScopes
