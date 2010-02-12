module ActiveModelScopes
  def self.included(base)
    base.named_scope :limit, lambda{|limit| {:limit => limit}}
    base.named_scope :where, lambda{|where| {:conditions => where}}
  end
end

ActiveRecord::Base.send :include, ActiveModelScopes
