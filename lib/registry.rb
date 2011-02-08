class Registry
  class << self
    delegate :add_callback, :each_callback, :find_first_callback, :to => :instance
  end

  def self.instance
    @instance ||= new
  end

  def add_callback( feature_name, hook_name, callback_name, value = nil, &block )
    if block and value
      raise "Cannot pass both a value and a block to add_callback"
    elsif @registry[feature_name][hook_name][callback_name]
      raise "Cannot redefine callback [#{feature_name.inspect},#{hook_name.inspect},#{callback_name}]"
    end

    @registry[feature_name][hook_name][callback_name] = value || block
  end

  def each_callback( feature_name, hook_name )
    hook = @registry[feature_name][hook_name]
    hook.sort.each do |callback_name,callback|
      yield( callback )
    end
    nil
  end

  def find_first_callback(feature_name, hook_name)
    self.each_callback(feature_name, hook_name) do |thing|
      if result = yield(thing)
        return result
      end
    end
    nil
  end

  def initialize
    @registry = Hash.new do |registry, feature_name|
      registry[feature_name] = Hash.new do |hooks, hook_name|
        hooks[hook_name] = Hash.new
      end
    end
  end
end
