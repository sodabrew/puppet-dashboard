module ObjectDaddy

  def self.included(klass)
    klass.extend ClassMethods
    if defined? ActiveRecord and klass < ActiveRecord::Base
      klass.extend RailsClassMethods    
      
      class << klass
        alias_method :validates_presence_of_without_object_daddy, :validates_presence_of
        alias_method :validates_presence_of, :validates_presence_of_with_object_daddy
      end   
    end
  end
    
  module ClassMethods
    attr_accessor :exemplars_generated, :exemplar_path, :generators
    attr_reader :presence_validated_attributes
    protected :exemplars_generated=
    
    # :call-seq:
    #   spawn()
    #   spawn() do |obj| ... end
    #   spawn(args)
    #   spawn(args) do |obj| ... end
    #
    # Creates a valid instance of this class, using any known generators. The
    # generated instance is yielded to a block if provided.
    def spawn(args = {})
      gather_exemplars
      if @concrete_subclass_name
        return block_given? \
          ? const_get(@concrete_subclass_name).spawn(args) {|instance| yield instance} \
          : const_get(@concrete_subclass_name).spawn(args)
      end
      generate_values(args)
      instance = new(args)
      yield instance if block_given?
      instance
    end

    # register a generator for an attribute of this class
    # generator_for :foo do |prev| ... end
    # generator_for :foo do ... end
    # generator_for :foo, value
    # generator_for :foo => value
    # generator_for :foo, :class => GeneratorClass
    # generator_for :foo, :method => :method_name
    def generator_for(handle, args = {}, &block)
      if handle.is_a?(Hash)
        raise ArgumentError, "only specify one attr => value pair at a time" unless handle.keys.length == 1
        gen_data = handle
        handle = gen_data.keys.first
        args = gen_data[handle]
      end
      
      raise ArgumentError, "an attribute name must be specified" unless handle = handle.to_sym
      
      unless args.is_a?(Hash)
        unless block
          retval = args
          block = lambda { retval }  # lambda { args } results in returning the empty hash that args gets changed to
        end
        args = {}  # args is assumed to be a hash for the rest of the method
      end
      
      if args[:start]
        block ||= lambda { |prev|  prev.succ }
      end
      
      if args[:method]
        h = { :method => args[:method].to_sym }
        h[:start] = args[:start] if args[:start]
        record_generator_for(handle, h)
      elsif args[:class]
        raise ArgumentError, "generator class [#{args[:class].name}] does not have a :next method" unless args[:class].respond_to?(:next)
        record_generator_for(handle, :class => args[:class])
      elsif block
        raise ArgumentError, "generator block must take an optional single argument" unless (-1..1).include?(block.arity)  # NOTE: lambda {} has an arity of -1, while lambda {||} has an arity of 0
        h = { :block => block }
        h[:start] = args[:start] if args[:start]
        record_generator_for(handle, h)
      else
        raise ArgumentError, "a block, :class generator, :method generator, or value must be specified to generator_for"
      end
    end

    def generates_subclass(subclass_name)
      @concrete_subclass_name = subclass_name.to_s
    end
    
    def gather_exemplars
      return if exemplars_generated
      if superclass.respond_to?(:gather_exemplars)
        superclass.gather_exemplars
        self.generators = (superclass.generators || {}).dup
      end

      exemplar_path.each do |raw_path|
        path = File.join(raw_path, "#{underscore(name)}_exemplar.rb")
        load(path) if File.exists?(path)
      end
      self.exemplars_generated = true
    end
    
    def presence_validated_attributes
      @presence_validated_attributes ||= {}
      attrs = @presence_validated_attributes
      if superclass.respond_to?(:presence_validated_attributes)
        attrs = superclass.presence_validated_attributes.merge(attrs)
      end
      attrs
    end
    
  protected
  
    # we define an underscore helper ourselves since the ActiveSupport isn't available if we're not using Rails
    def underscore(string)
      string.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end
    
    def record_generator_for(handle, generator)
      self.generators ||= {}
      raise ArgumentError, "a generator for attribute [:#{handle}] has already been specified" if (generators[handle] || {})[:source] == self
      generators[handle] = { :generator => generator, :source => self }
    end
  
  private
    
    def generate_values(args)
      (generators || {}).each_pair do |handle, gen_data|
        next if args.include?(handle) or args.include?(handle.to_s)
        
        generator = gen_data[:generator]
        if generator[:block]
          process_generated_value(args, handle, generator, generator[:block])
        elsif generator[:method]
          method = method(generator[:method])
          if method.arity == 1
            process_generated_value(args, handle, generator, method)
          else
            args[handle] = method.call
          end
        elsif generator[:class]
          args[handle] = generator[:class].next
        end
      end
      
      generate_missing(args)
    end
    
    def process_generated_value(args, handle, generator, block)
      if generator[:start]
        value = generator[:start]
        generator.delete(:start)
      else
        value = block.call(generator[:prev])
      end
      generator[:prev] = args[handle] = value
    end
    
    def generate_missing(args)
      if presence_validated_attributes and !presence_validated_attributes.empty?
        req = {}
        (presence_validated_attributes.keys - args.keys).each {|a| req[a.to_s] = true } # find attributes required by validates_presence_of not already set
        
        belongs_to_associations = reflect_on_all_associations(:belongs_to).to_a
        missing = belongs_to_associations.select { |a|  req[a.name.to_s] or req[a.primary_key_name.to_s] }
        if create_scope = scope(:create)
          missing.reject! { |a|   create_scope.include?(a.primary_key_name) }
        end
        missing.reject! { |a|  [a.name, a.primary_key_name].any? { |n|  args.stringify_keys.include?(n.to_s) } }
        missing.each {|a| args[a.name] = a.class_name.constantize.generate }
      end
    end
  end
  
  module RailsClassMethods
    def exemplar_path
      dir = File.directory?(File.join(RAILS_ROOT, 'spec')) ? 'spec' : 'test'
      File.join(RAILS_ROOT, dir, 'exemplars')
    end
    
    def validates_presence_of_with_object_daddy(*attr_names)
      @presence_validated_attributes ||= {}
      new_attr = attr_names.dup
      new_attr.pop if new_attr.last.is_a?(Hash)
      new_attr.each {|a| @presence_validated_attributes[a] = true }
      validates_presence_of_without_object_daddy(*attr_names)
    end
    
    # :call-seq:
    #   generate()
    #   generate() do |obj| ... end
    #   generate(args)
    #   generate(args) do |obj| ... end
    #
    # Creates and tries to save an instance of this class, using any known
    # generators. The generated instance is yielded to a block if provided.
    #
    # This will not raise errors on a failed save. Use generate! if you
    # want errors raised.
    def generate(args = {})
      spawn(args) do |instance|
        instance.save
        yield instance if block_given?
      end
    end
    
    # :call-seq:
    #   generate()
    #   generate() do |obj| ... end
    #   generate(args)
    #   generate(args) do |obj| ... end
    #
    # Creates and tries to save! an instance of this class, using any known
    # generators. The generated instance is yielded to a block if provided.
    #
    # This will raise errors on a failed save. Use generate if you do not want
    # errors raised.
    def generate!(args = {})
      spawn(args) do |instance|
        instance.save!
        yield instance if block_given?
      end
    end
  end
end
