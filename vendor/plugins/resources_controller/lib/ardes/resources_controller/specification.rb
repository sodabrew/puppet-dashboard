module Ardes#:nodoc:
  module ResourcesController
    # This class holds all the info that is required to find a resource, or determine a name prefix, based on a route segment
    # or segment pair (e.g. /blog or /users/3).
    #
    # You don't need to instantiate this class directly - it is created by ResourcesController::ClassMethods#nested_in,
    # ResourcesController#map_resource (and ResourcesController::InstanceMethods#load_wildcard)
    #
    # This is primarily a container class.  A summary of its behaviour:
    # 1. setting defaults for its own variables on initialize, and
    # 2. finding an enclosing resource, given a controller object
    #
    class Specification
      attr_reader :name, :source, :klass, :key, :name_prefix, :segment, :find
      attr_accessor :as
      
      # factory for Specification and SingletonSpecification
      #
      # you can call Specification.new 'name', :singleton => true
      def self.new(name, options = {}, &block)
        options.delete(:singleton) ? SingletonSpecification.new(name, options, &block) : super(name, options, &block)
      end
      
      # Example Usage
      #
      #  Specifcation.new <name>, <options hash>, <&block>
      #
      # _name_ should always be singular.
      #
      # Options:
      #
      # * <tt>:singleton:</tt> (default false) set this to true if the resource is a Singleton
      # * <tt>:find:</tt> (default null) set this to a symbol or Proc to specify how to find the resource.
      #   Use this if the resource is found in an unconventional way
      #
      # Options for unconvential use (otherwise these are all inferred from the _name_)
      # * <tt>:source:</tt> a plural string or symbol (e.g. :users).  This is used to find the class or association name
      # * <tt>:class:</tt> a Class.  This is the class of the resource (if it can't be inferred from _name_ or :source)
      # * <tt>:key:</tt> (e.g. :user_id) used to find the resource id in params
      # * <tt>:name_prefix:</tt> (e.g. 'user_') (set this to false if you want to specify that there is none)
      # * <tt>:segment:</tt> (e.g. 'users') the segment name in the route that is matched
      #
      # Passing a block is the same as passing :find => Proc
      def initialize(spec_name, options = {}, &block)
        options.assert_valid_keys(:class, :source, :key, :find, :name_prefix, :segment, :as)
        @name        = spec_name.to_s
        @find        = block || options.delete(:find)
        @segment     = (options[:segment] && options[:segment].to_s) || name.pluralize
        @source      = (options[:source] && options[:source].to_s) || name.pluralize
        @name_prefix = options[:name_prefix] || (options[:name_prefix] == false ? '' : "#{name}_")
        @klass       = options[:class] || ((source && source.classify) || name.camelize).constantize
        @key         = (options[:key] && options[:key].to_s) || name.foreign_key
        @as          = options[:as]
      end

      # returns false
      def singleton?
        false
      end

      # given a controller object, returns the resource according to this specification
      def find_from(controller)
        find ? find_custom(controller) : find_resource(controller)
      end
      
      # finds the resource using the custom :find Proc or symbol
      def find_custom(controller)
        raise "This specification has no custom :find attribute" unless find
        find.is_a?(Proc) ? controller.instance_eval(&find) : controller.send(find)
      end
      
      # finds the resource on a controller using enclosing resources or resource class
      def find_resource(controller)
        (controller.enclosing_resource ? controller.enclosing_resource.send(source) : klass).find controller.params[key]
      end
    end
  
    # A Singleton Specification
    class SingletonSpecification < Specification
      # Same as Specification except: 
      #
      # Options for unconvential use (otherwise these are all inferred from the _name_) 
      # * <tt>:source:</tt> a singular string or symbol (e.g. :blog).  This is used to find the class or association name
      # * <tt>:segment:</tt> (e.g. 'blog') the segment name in the route that is matched
      def initialize(spec_name, options = {}, &block)
        options[:segment] ||= spec_name.to_s
        options[:source]  ||= spec_name.to_s
        options[:class]   ||= (options[:source] || spec_name).to_s.camelize.constantize
        super(spec_name, options, &block)
      end

      # returns true
      def singleton?
        true
      end
    
      # finds the resource from the enclosing resource.  Raise CantFindSingleton if there is no enclosing resource
      def find_resource(controller)
        ResourcesController.raise_cant_find_singleton(name, klass) unless controller.enclosing_resource
        controller.enclosing_resource.send(source)
      end
    end
  end
end