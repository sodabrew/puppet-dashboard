module Ardes#:nodoc:
  module ResourcesController
    # Often it won't be appropriate to re-use views, but
    # sometimes it is.  These helper methods enable reuse by referencing whatever resource the 
    # controller is for.
    #
    # ==== Example:
    #
    # instead of writing:
    #  <% for event in @events %>
    #    <%= link_to 'edit', edit_event_path(event) %>
    #
    # you may write:
    #  <% for event in resources %>
    #    <%= link_to 'edit', edit_resource_path(event) %>
    #
    # == Enclosing resource
    #
    # For controllers with enclosing resources instead of writing:
    #  <%= link_to 'back to Forum', forum_path(@forum) %>
    #
    # you may write: (which will work for any enclosing path)
    #  <%= link_to "back to #{enclosing_resource.class.name.titleize}", enclosing_resource_path %>
    #
    # == Enclosing named routes:
    #
    # In addition you can reference named routes that are 'below' the current resource
    # by appending resource_ to that named route.
    #
    # ==== Example: shared polymorphic view
    #
    # Let's say you have a resource controller for tags, and you're writing the 
    # taggable views.  In a view shared amongst taggables you can write
    #
    #  <%= link_to 'tags', resource_tags_path %>
    #  <%= link_to 'edit tag', edit_resource_tag_path(@tag) %>
    # 
    # or:
    #  <% for taggable in resources %>
    #    <%= link_to 'tags', resource_tags_path(taggable) %>
    #
    module Helper
      def self.included(base)
        base.class_eval do
          alias_method_chain :method_missing, :named_route_helper
          alias_method_chain :respond_to?, :named_route_helper
          delegate :resource_name, :resources_name, :resource, :resources, :enclosing_resource, :enclosing_resource_name, :to => :controller
        end
      end

      # Calls form_for with the apropriate action and method for the resource
      #
      # resource.new_record? is used to decide between a create or update action
      #
      # You can optionally pass a resource object, default is to use self.resource
      #
      # You may also override the url by passing <tt>:url</tt>, or pass extra options
      # to resource path url with <tt>:url_options</tt>
      #
      # === Example
      # 
      #   <% form_for_resource do |f| %>
      #     <%= f.text_field :name %>
      #     <%= f.submit resource.new_record? ? 'Create' : 'Update'
      #   <% end %>
      #
      #   <% for attachment in resources %>
      #     <% form_for_resource attachment, :html => {:multipart => true} %>
      #       <%= f.file_field :uploaded_data %>
      #       <%= f.submit 'Update' %>
      #     <% end %>
      #   <% end %>
      #
      def form_for_resource(*args, &block)
        options = args.extract_options!
        resource = args[0] || self.resource
        form_for(resource_name, resource, form_for_resource_options(resource, options), &block)
      end

      # same API as form_for_resource
      def remote_form_for_resource(*args, &block)
        options = args.extract_options!
        resource = args[0] || self.resource
        remote_form_for(resource_name, resource, form_for_resource_options(resource, options), &block)
      end
    
      # print the error messages for the current resource
      def error_messages_for_resource
        error_messages_for resource_name
      end
      
      # Delegate named_route helper method to the controller.  Create the delegation
      # to short circuit the method_missing call for future invocations.
      def method_missing_with_named_route_helper(method, *args, &block)
        if controller.resource_named_route_helper_method?(method)
          self.class.send(:delegate, method, :to => :controller)
          controller.send(method, *args)
        else
          method_missing_without_named_route_helper(method, *args, &block)
        end
      end

      # delegate url help method creation to the controller
      def respond_to_with_named_route_helper?(*args)
        respond_to_without_named_route_helper?(*args) || controller.resource_named_route_helper_method?(args.first)
      end
    
    private
      def form_for_resource_options(resource, options)
        returning options.dup do |options|
          options[:html] ||= {}
          options[:html][:method] ||= resource.new_record? ? :post : :put
          args = options[:url_options] ? [options.delete(:url_options)] : []
          options[:url] ||= if resource.new_record?
            controller.resource_specification.singleton? ? resource_path(*args) : resources_path(*args)
          else
            controller.resource_specification.singleton? ? resource_path(*args) : resource_path(*([resource] + args))
          end
        end
      end
    end
  end
end