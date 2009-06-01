module Ardes#:nodoc:
  module ResourcesController
    
    class CantMapRoute < ArgumentError #:nodoc:
    end
    
    # This module provides methods are provided to aid in writing inheritable controllers.
    #
    # When writing an action that redirects to the list of resources, you may use *resources_url* and the controller
    # will call the url_writer method appropriate to what the controller is a resources controller for.
    #
    # If the route specified requires a member argument and you don't provide it, the current resource is used.
    #
    # In general you may subsitute 'resource' for the current (maybe polymorphic) resource. e.g.
    #
    # You may also substitute 'enclosing_resource' to get urls for the enclosing resource
    #
    #    (in attachable/attachments where attachable is a Post)
    #
    #    resources_path                        # => post_attachments_path
    #    formatted_edit_resource_path('js')    # => formatted_post_attachments_path(<current post>, <current attachment>, 'js')
    #    resource_tags_path                    # => post_attachments_tags_paths(<current post>, <current attachment>)
    #    resource_tags_path(foo)               # => post_attachments_tags_paths(<current post>, foo)
    #
    #    enclosing_resource_path               # => post_path(<current post>)
    #    enclosing_resources_path              # => posts_path
    #    enclosing_resource_tags_path          # => post_tags_path(<current post>)
    #    enclosing_resource_path(2)            # => post_path(2)
    #
    # The enclosing_resource stuff works with deep nesting if you're into that.
    #
    # These methods are defined as they are used.  The ActionView Helper module delegates to the current controller to access these
    # methods
    module NamedRouteHelper
      def self.included(base)
        base.class_eval do
          alias_method_chain :method_missing, :named_route_helper
          alias_method_chain :respond_to?, :named_route_helper
        end
        base.hide_action *instance_methods
        base.hide_action :method_missing_without_named_route_helper, :respond_to_without_named_route_helper?, :respond_to?
      end

      def method_missing_with_named_route_helper(method, *args, &block)
        # TODO: test that methods are only defined once
        if resource_named_route_helper_method?(method, raise_error = true) 
          define_resource_named_route_helper_method(method)
          send(method, *args)
        elsif resource_named_route_helper_method_for_name_prefix?(method)
          define_resource_named_route_helper_method_for_name_prefix(method)
          send(method, *args)
        else
          method_missing_without_named_route_helper(method, *args, &block)
        end
      end

      def respond_to_with_named_route_helper?(*args)
        respond_to_without_named_route_helper?(*args) || resource_named_route_helper_method?(args.first)
      end

      # return true if the passed method (e.g. 'resources_path') corresponds to a defined
      # named route helper method
      def resource_named_route_helper_method?(resource_method, raise_error = false)
        if resource_method.to_s =~ /_(path|url)$/ && resource_method.to_s =~ /(^|^.*_)enclosing_resource(s)?_/
          _, route_method = *route_and_method_from_enclosing_resource_method_and_name_prefix(resource_method, name_prefix)
        elsif resource_method.to_s =~ /_(path|url)$/ && resource_method.to_s =~ /(^|^.*_)resource(s)?_/
          _, route_method = *route_and_method_from_resource_method_and_name_prefix(resource_method, name_prefix)
        else
          return false
        end
        respond_to_without_named_route_helper?(route_method) || (raise_error && raise_resource_url_mapping_error(resource_method, route_method))
      end

    private
      def raise_resource_url_mapping_error(resource_method, route_method)
        raise CantMapRoute, <<-end_str
Tried to map :#{resource_method} to :#{route_method},
which doesn't exist. You may not have defined the route in config/routes.rb.

Or, if you have unconventianal route names or name prefixes, you may need
to explicictly set the :route option in resources_controller_for, and set
the :name_prefix option on your enclosing resources.

Currently:
  :route is '#{route_name}'
  generated name_prefix is '#{name_prefix}'
        end_str
      end
      
      # passed something like (^|.*_)enclosing_resource(s)_.*(url|path)$, will 
      # return the [route, route_method]  for the expanded resource
      def route_and_method_from_enclosing_resource_method_and_name_prefix(method, name_prefix)
        if enclosing_resource
          enclosing_route = name_prefix.sub(/_$/,'')
          route_method = method.to_s.sub(/enclosing_resource(s)?/) { $1 ? enclosing_route.pluralize : enclosing_route }
          return [ActionController::Routing::Routes.named_routes.get(route_method.sub(/_(path|url)$/,'').to_sym), route_method]
        else
          raise NoMethodError, "Tried to map :#{method} but there is no enclosing_resource for this controller"
        end
      end
      
      # passed something like (^|.*_)resource(s)_.*(url|path)$, will 
      # return the [route, route_method]  for the expanded resource
      def route_and_method_from_resource_method_and_name_prefix(method, name_prefix)
        route_method = method.to_s.sub(/resource(s)?/) { $1 ? "#{name_prefix}#{route_name.pluralize}" : "#{name_prefix}#{route_name}" }
        return [ActionController::Routing::Routes.named_routes.get(route_method.sub(/_(path|url)$/,'').to_sym), route_method]
      end
      
      # defines a method that calls the appropriate named route method, with appropraite args.
      def define_resource_named_route_helper_method(method)
        self.class.send :module_eval, <<-end_eval, __FILE__, __LINE__
          def #{method}(*args)
            send "#{method}_for_\#{name_prefix}", *args
          end
        end_eval
      end

      def resource_named_route_helper_method_for_name_prefix?(method)
        method.to_s =~ /_for_.*$/ && resource_named_route_helper_method?(method.to_s.sub(/_for_.*$/,''))
      end

      def define_resource_named_route_helper_method_for_name_prefix(method)
        resource_method = method.to_s.sub(/_for_.*$/,'')
        name_prefix = method.to_s.sub(/^.*_for_/,'')
        if resource_method =~ /enclosing_resource/
          route, route_method = *route_and_method_from_enclosing_resource_method_and_name_prefix(resource_method, name_prefix)
          required_args = (route.significant_keys - [:controller, :action, :format]).size
        
          self.class.send :module_eval, <<-end_eval, __FILE__, __LINE__
            def #{method}(*args)
              options = args.extract_options!
              args = args.size < #{required_args} ? enclosing_collection_resources + args : enclosing_collection_resources - [enclosing_resource] + args
              args = args + [options] if options.size > 0
              send :#{route_method}, *args
            end
          end_eval
                  
        else
          route, route_method = *route_and_method_from_resource_method_and_name_prefix(resource_method, name_prefix)
          required_args = (route.significant_keys - [:controller, :action, :format]).size

          self.class.send :module_eval, <<-end_eval, __FILE__, __LINE__
            def #{method}(*args)
              options = args.extract_options!
              #{"args = [resource] + args if enclosing_collection_resources.size + args.size < #{required_args}" if required_args > 0}
              args = args + [options] if options.size > 0
              send :#{route_method}, *(enclosing_collection_resources + args)
            end
          end_eval
        end
        
        self.class.send :private, method
      end
    end
  end
end