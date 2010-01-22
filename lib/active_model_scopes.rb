module ActiveModelScopes
  def self.included(base)
    base.named_scope :limit, lambda{|limit| {:limit => limit}}
  end
end

ActiveRecord::Base.send :include, ActiveModelScopes
