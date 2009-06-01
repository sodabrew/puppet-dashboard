module Ardes#:nodoc:
  # With resources_controller (http://svn.ardes.com/rails_plugins/resources_controller) you can quickly add
  # an ActiveResource compliant controller for your your RESTful models.
  # 
  # = Examples
  # Here are some examples - for more on how to use  RC go to the Usage section at the bottom,
  # for syntax head to resources_controller_for
  #
  # ==== Example 1: Super simple usage
  # Here's a simple example of how it works with a Forums has many Posts model:
  # 
  #   class ForumsController < ApplicationController
  #     resources_controller_for :forums
  #   end
  #
  # Your controller will get the standard CRUD actions, @forum will be set in member actions, @forums in
  # index.
  # 
  # ==== Example 2: Specifying enclosing resources
  #   class PostsController < ApplicationController
  #     resources_controller_for :posts, :in => :forum
  #   end
  #
  # As above, but the controller will load @forum on every action, and use @forum to find and create @posts
  #
  # ==== Wildcard enclosing resources
  # All of the above examples will work for any routes that match what it specified
  #
  #              PATH                     RESOURCES CONTROLLER WILL DO:
  #
  #  Example 1  /forums                   @forums = Forum.find(:all)
  #
  #             /users/2/forums           @user = User.find(2)
  #                                       @forums = @user.forums.find(:all)
  #
  #  Example 2  /posts                    This won't work as the controller specified
  #                                       that :posts are :in => :forum
  #
  #             /forums/2/posts           @forum = Forum.find(2)
  #                                       @posts = @forum.posts.find(:all)
  #
  #             /sites/4/forums/3/posts   @site = Site.find(4)
  #                                       @forum = @site.forums.find(3)
  #                                       @posts = @forum.posts.find(:all)
  #
  #             /users/2/posts/1          This won't work as the controller specified
  #                                       that :posts are :in => :forum
  #                                       
  #
  # It is up to you which routes to open to the controller (in config/routes.rb).  When
  # you do, RC will use the route segments to drill down to the specified resource.  This means
  # that if User 3 does not have Post 5, then /users/3/posts/5 will raise a RecordNotFound Error.
  # You dont' have to write any extra code to do this oft repeated controller pattern.
  #
  # With RC, your route specification flows through to the controller - no need to repeat yourself.
  #
  # If you don't want to have RC match wildcard resources just pass :load_enclosing => false
  #
  #   resources_controller_for :posts, :in => :forum, :load_enclosing => false
  #
  # ==== Example 3: Singleton resource
  # Here's an example of a singleton, the account pattern that is so common.
  #
  #   class AccountController < ApplicationController
  #     resources_controller_for :account, :class => User, :singleton => true do
  #       @current_user
  #     end
  #   end
  #
  # Your controller will use the block to find the resource.  The @account will be assigned to @current_user
  #
  # ==== Example 4: Allowing PostsController to be used all over
  # First thing to do is remove :in => :forum
  #
  #   class PostsController < ApplicationController
  #     resources_controller_for :posts
  #   end
  #
  # This will now work for /users/2/posts.
  #
  # ==== Example 4 and a bit: Mapping non standard resources
  # How about /account/posts?  The account is found in a non standard way - RC won't be able
  # to figure out how tofind it if it appears in the route.  So we give it some help.
  #
  # (in PostsController)
  #
  #   map_enclosing_resource :account, :singleton => true, :class => User, :find => :current_user
  # 
  # Now, if :account apears in any part of a route (for PostsController) it will be mapped to
  # (in this case) the current_user method of teh PostsController.
  #
  # To make the :account mapping available to all, just chuck it in ApplicationController
  # 
  # This will work for any resource which can't be inferred from its route segment name
  #
  #   map_enclosing_resource :users, :segment => :peeps, :key => 'peep_id'
  #   map_enclosing_resource :posts, :class => OddlyNamedPostClass
  #
  # ==== Example 5: Singleton association
  # Here's another singleton example - one where it corresponds to a has_one or belongs_to association
  #
  #   class ImageController < ApplicationController
  #     resources_controller_for :image, :singleton => true
  #   end
  #
  # When invoked with /users/3/image RC will find @user, and use @user.image to find the resource, and
  # @user.build_image, to create a new resource. 
  #
  # ==== Example 6: :resource_path (equivalent resource path): aliasing a named route to a RESTful route
  #
  # You may have a named route that maps a url to a particular controller and action,
  # this causes resources_controller problems as it relies on the route to load the
  # resources.  You can get around this by specifying :resource_path as a param in routes.rb
  #
  #   map.root :controller => :forums, :action => :index, :resource_path => '/forums'
  #
  # When the controller is invoked via the '' url, rc will use :resource_path to recognize the
  # route.
  #
  # ==== Putting it all together
  #
  # An exmaple app
  #
  # config/routes.rb:
  #  
  #  map.resource :account do |account|
  #    account.resource :image
  #    account.resources :posts
  #  end
  #
  #  map.resources :users do |user|
  #    user.resource :image
  #    user.resources :posts
  #  end
  #
  #  map.resources :forums do |forum|
  #    forum.resources :posts
  #    forum.resource :image
  #  end
  #
  #  map.root :controller => :forums, :action => :index, :resource_path => '/forums'
  #
  # app/controllers:
  #
  #  class ApplicationController < ActionController::Base
  #    map_enclosing_resource :account, :singleton => true, :find => :current_user
  #
  #    def current_user # get it from session or whatnot
  #  end
  #
  #  class ForumsController < AplicationController
  #    resources_controller_for :forums
  #  end
  #    
  #  class PostsController < AplicationController
  #    resources_controller_for :posts
  #  end
  #
  #  class UsersController < AplicationController
  #    resources_controller_for :users
  #  end
  #
  #  class ImageController < AplicationController
  #    resources_controller_for :image, :singleton => true
  #  end
  #
  #  class AccountController < ApplicationController
  #    resources_controller_for :account, :singleton => true, :find => :current_user
  #  end
  #
  # This is how the app will handle the following routes:
  #
  #  PATH                   CONTROLLER    WHICH WILL DO:
  #  
  #  /forums                forums        @forums = Forum.find(:all)
  #  
  #  /forums/2/posts        posts         @forum = Forum.find(2)
  #                                       @posts = @forum.forums.find(:all)
  #
  #  /forums/2/image        image         @forum = Forum.find(2)
  #                                       @image = @forum.image   
  #  
  #  /image                       <no route>
  #
  #  /posts                       <no route>
  #
  #  /users/2/posts/3       posts         @user = User.find(2)
  #                                       @post = @user.posts.find(3)
  #  
  #  /users/2/image POST    image         @user = User.find(2)
  #                                       @image = @user.build_image(params[:image])
  #
  #  /account               account       @account = self.current_user
  #
  #  /account/image         image         @account = self.current_user
  #                                       @image = @account.image
  #
  #  /account/posts/3 PUT   posts         @account = self.current_user
  #                                       @post = @account.posts.find(3)
  #                                       @post.update_attributes(params[:post])
  #
  # === Views
  #
  # Ok - so how do I write the views?  
  #
  # For most cases, just in exactly the way you would expect to.  RC sets the instance variables
  # to what they should be.
  #
  # But, in some cases, you are going to have different variables set - for example
  #
  #   /users/1/posts    =>  @user, @posts
  #   /forums/2/posts   =>  @forum, @posts
  # 
  # Here are some options (all are appropriate for different circumstances):
  # * test for the existence of @user or @forum in the view, and display it differently
  # * have two different controllers UserPostsController and ForumPostsController, with different views
  #   (and direct the routes to them in routes.rb)
  # * use enclosing_resource - which always refers to the... immediately enclosing resource.
  #
  # Using the last technique, you might write your posts index as follows
  # (here assuming that both Forum and User have .name)
  #
  #   <h1>Posts for <%= link_to enclosing_resource_path, "#{enclosing_resource_name.humanize}: #{enclosing_resource.name}" %></h1>
  #
  #   <%= render :partial => 'post', :collection => @posts %>
  #
  # Notice *enclosing_resource_name* - this will be something like 'user', or 'post'.
  # Also *enclosing_resource_path* - in RC you get all of the named route helpers relativised to the current resource
  # and enclosing_resource.  See NamedRouteHelper for more details.
  #
  # This can useful when writing the _post partial:
  #
  #   <p>
  #     <%= post.name %>
  #     <%= link_to 'edit', edit_resource_path(tag) %>
  #     <%= link_to 'destroy', resource_path(tag), :method => :delete %>
  #   </p>
  #
  # when viewed at /users/1/posts it will show
  #
  #  <p>
  #    Cool post
  #    <a href="/users/1/posts/1/edit">edit</a>
  #    <a href="js nightmare with /users/1/posts/1">delete</a>
  #  </p>
  #  ...
  #
  # when viewd at /forums/1/posts it will show
  #
  #  <p>
  #    Other post
  #    <a href="/forums/1/posts/3/edit">edit</a>
  #    <a href="js nightmare with /forums/1/posts/3">delete</a>
  #  </p>
  #  ...
  #
  # This is like polymorphic urls, except that RC will just use whatever enclosing resources are loaded to generate the urls/paths.
  #
  # = Usage
  # To use RC, there are just three class methods on controller to learn.
  #
  # resources_controller_for <name>, <options>, <&block>
  #
  # ClassMethods#nested_in <name>, <options>, <&block>
  #
  # map_enclosing_resource <name>, <options>, <&block>
  #
  # === Customising finding and creating
  # If you want to implement something like query params you can override *find_resources*.  If you want to change the 
  # way your new resources are created you can override *new_resource*.
  #
  #   class PostsController < ApplicationController
  #     resources_controller_for :posts
  # 
  #     def find_resources
  #       resource_service.find :all, :order => params[:sort_by]
  #     end
  #
  #     def new_resource
  #       returning resource_service.new(params[resource_name]) do |post|
  #         post.ip_address = request.remote_ip
  #       end
  #     end
  #   end
  #
  # In the same way, you can override *find_resource*.
  #
  # === Writing controller actions
  #
  # You can make use of RC internals to simplify your actions.
  #
  # Here's an example where you want to re-order an acts_as_list model.  You define a class method
  # on the model (say *order_by_ids* which takes and array of ids).  You can then make use of *resource_service*
  # (which makes use of awesome rails magic) to send correctly scoped messages to your models.
  #
  # Here's how to write an order action
  #
  #   def order
  #     resource_service.order_by_ids["things_order"]
  #   end
  #
  # the route
  #
  #   map.resources :things, :collection => {:order => :put}
  #
  # and the view can conatin a scriptaculous drag and drop with param name 'things_order'
  #
  # When this controller is invoked of /things the :order_by_ids message will be sent to the Thing class,
  # when it's invoked by /foos/1/things, then :order_by_ids message will be send to Foo.find(1).things association
  #
  # === using non standard ids
  #
  # Lets say you want to set to_param to login, and use find_by_login
  # for your users in your URLs, with routes as follows:
  #
  #   map.reosurces :users do |user|
  #     user.resources :addresses
  #   end
  #
  # First, the users controller needs to find reosurces using find_by_login
  #
  #   class UsersController < ApplicationController
  #     resources_controller_for :users
  #
  #   protected
  #     def find_resource(id = params[:id])
  #       resource_service.find_by_login(id)
  #     end
  #   end
  #
  # This controller will find users (for editing, showing, and destroying) as
  # directed.  (this controller will work for any route where user is the
  # last resource, including the /users/dave route)
  #
  # Now you need to specify that the user as enclosing resource needs to be found
  # with find_by_login.  For the addresses case above, you would do this:
  #
  #   class AddressesController < ApplicationController
  #     resources_controller_for :addresses
  #     nested_in :user do
  #       User.find_by_login(params[:user_id])
  #     end
  #   end
  #
  # If you wanted to open up more nested resources under user, you could repeat
  # this specification in all such controllers, alternatively, you could map the
  # resource in the ApplicationController, which would be usable by any controller
  #
  # If you know that user is never nested (i.e. /users/dave/addresses), then do this:
  #
  #   class ApplicationController < ActionController::Base
  #     map_enclosing_resource :user do
  #       User.find(params[:user_id])
  #     end
  #   end
  #
  # or, if user is sometimes nested (i.e. /forums/1/users/dave/addresses), do this:
  #
  #     map_enclosing_resource :user do
  #       ((enclosing_resource && enclosing_resource.users) || User).find(params[:user_id])
  #     end
  #
  # Your Addresses controller will now be the very simple one, and the resource map will
  # load user as specified when it is hit by a route /users/dave/addresses.
  #
  #   class AddressesController < ApplicationController
  #     resources_controller_for :addresses
  #   end
  #
  module ResourcesController
    mattr_accessor :actions, :singleton_actions
    self.actions = Ardes::ResourcesController::Actions
    self.singleton_actions = Ardes::ResourcesController::SingletonActions
    
    def self.extended(base)
      base.class_eval do
        class_inheritable_reader :resource_specification_map
        write_inheritable_attribute(:resource_specification_map, {})
      end
    end
    
    # Specifies that this controller is a REST style controller for the named resource
    #
    # Enclosing resources are loaded automatically by default, you can turn this off with
    # :load_enclosing (see options below)
    #
    # resources_controller_for <name>, <options>, <&block>
    #
    # ==== Options:
    # * <tt>:singleton:</tt> (default false) set this to true if the resource is a Singleton
    # * <tt>:find:</tt> (default null) set this to a symbol or Proc to specify how to find the resource.
    #   Use this if the resource is found in an unconventional way.  Passing a block has the same effect as
    #   setting :find => a Proc
    # * <tt>:in:</tt> specify the enclosing resources, by name.  ClassMethods#nested_in can be used to 
    #   specify this more fully.
    # * <tt>:load_enclosing:</tt> (default true) loads enclosing resources automatically.
    # * <tt>:actions:</tt> (default nil) set this to false if you don't want the default RC actions.  Set this
    #   to a module to use that module for your own actions.
    # * <tt>:only:</tt> only include the specified actions.
    # * <tt>:except:</tt> include all actions except the specified actions.
    #
    # ===== Options for unconvential use
    # (otherwise these are all inferred from the _name_)
    # * <tt>:route:</tt> the route name (without name_prefix) if it can't be inferred from _name_.
    #   For a collection resource this should be plural, for a singleton it should be singular.
    # * <tt>:source:</tt> a string or symbol (e.g. :users, or :user).  This is used to find the class or association name
    # * <tt>:class:</tt> a Class.  This is the class of the resource (if it can't be inferred from _name_ or :source)
    # * <tt>:segment:</tt> (e.g. 'users') the segment name in the route that is matched
    #
    # === The :in option
    # The default behavior is to set up before filters that load the enclosing resource, and to use associations on
    # that model to find and create the resources.  See ClassMethods#nested_in for more details on this, and
    # customising the default behaviour.
    # 
    # === load_enclosing_resources
    # By default, a before_filter is added by resources_controller called :load_enclosing_resources - which
    # does all the work of loading the enclosing resources.  You can use ActionControllers standard filter
    # mechanisms to control when this filter is invoked.  For example - you can choose not to load resources
    # on an action
    #
    #   resources_controller_for :foos
    #   skip_before_filter :load_enclosing_resources, :only => :static_page
    #
    # Or, you can change the order of when the filter is invoked by adding the filter call yourself (rc will
    # only add the filter if it doesn't exist)
    #
    #   before_filter :do_something
    #   prepend_before_filter :load_enclosing_resources
    #   resources_controller_for :foos
    #   before_filter :do_something_else     # chain => [:load_enclosing_resources, :do_something, :do_something_else]
    #
    # === Default actions module
    # If you have your own actions module you prefer to use other than the standard resources_controller ones
    # you can set Ardes::ResourcesController.actions to that module to have this be included by default
    #
    #   Ardes::ResourcesController.actions = MyAwesomeActions
    #   Ardes::ResourcesController.singleton_actions = MyAweseomeSingletonActions
    #
    #   class AwesomenessController < ApplicationController
    #     resources_controller_for :awesomenesses # includes MyAwesomeActions by default
    #   end
    def resources_controller_for(name, options = {}, &block)
      options.assert_valid_keys(:class, :source, :singleton, :actions, :in, :find, :load_enclosing, :route, :segment, :as, :only, :except)
      when_options = {:only => options.delete(:only), :except => options.delete(:except)}
      
      unless included_modules.include? ResourcesController::InstanceMethods
        class_inheritable_reader :specifications, :route_name
        hide_action :specifications, :route_name
        extend  ResourcesController::ClassMethods
        helper  ResourcesController::Helper
        include ResourcesController::InstanceMethods, ResourcesController::NamedRouteHelper
      end

      before_filter(:load_enclosing_resources, when_options) unless load_enclosing_resources_filter_exists?
      
      write_inheritable_attribute(:specifications, [])
      specifications << '*' unless options.delete(:load_enclosing) == false
      
      unless (actions = options.delete(:actions)) == false
        actions ||= options[:singleton] ? Ardes::ResourcesController.singleton_actions : Ardes::ResourcesController.actions
        include_actions actions, when_options
      end
      
      route = (options.delete(:route) || name).to_s
      name = options[:singleton] ? name.to_s : name.to_s.singularize
      write_inheritable_attribute :route_name, options[:singleton] ? route : route.singularize
      
      nested_in(*options.delete(:in)) if options[:in]
      
      write_inheritable_attribute(:resource_specification, Specification.new(name, options, &block))
    end
    
    # Creates a resource specification mapping.  Use this to specify how to find an enclosing resource that
    # does not obey usual rails conventions.  Most commonly this would be a singleton resource.
    #
    # See Specification#new for details of how to call this
    def map_enclosing_resource(name, options = {}, &block)
      spec = Specification.new(name, options, &block)
      resource_specification_map[spec.segment] = spec
    end
    
    # this will be deprecated soon as it's badly named - use map_enclosing_resource
    def map_resource(*args, &block)
      map_enclosing_resource(*args, &block)
    end
    
    # Include the specified module, optionally specifying which public methods to include, for example:
    #  include_actions ActionMixin, :only => :index
    #  include_actions ActionMixin, :except => [:create, :new]
    def include_actions(mixin, options = {})
      mixin.extend(IncludeActions) unless mixin.respond_to?(:include_actions)
      mixin.include_actions(self, options)
    end
  
  private
    def load_enclosing_resources_filter_exists?
      if respond_to?(:find_filter) # BC 2.0-stable branch
        find_filter(:load_enclosing_resources)
      else
        filter_chain.detect {|c| c.method == :load_enclosing_resources}
      end
    end
  
    module ClassMethods
      # Specifies that this controller has a particular enclosing resource.
      #
      # This can be called with an array of symbols (in which case options can't be specified) or
      # a symbol with options.
      #
      # See Specification#new for details of how to call this.
      def nested_in(*names, &block)
        options = names.extract_options!
        raise ArgumentError, "when giving more than one nesting, you may not specify options or a block" if names.length > 1 and (block_given? or options.length > 0)
        
        # convert :polymorphic option to '?'
        if options.delete(:polymorphic)
          raise ArgumentError, "when specifying :polymorphic => true, no block or other options may be given" if block_given? or options.length > 0
          names = ["?#{names.first}"] 
        end

        # ignore first '*' if it has already been specified by :load_enclosing == true
        names.shift if specifications == ['*'] && names.first == '*'
        
        names.each do |name|
          ensure_sane_wildcard if name == '*'
          specifications << (name.to_s =~ /^(\*|\?(.*))$/ ? name.to_s : Specification.new(name, options, &block))
        end
      end
      
      # return the class resource_specification
      def resource_specification
        read_inheritable_attribute(:resource_specification)
      end
      
    private
      # ensure that specifications array is determinate w.r.t route matching
      def ensure_sane_wildcard
        idx = specifications.length
        while (idx -= 1) >= 0
          if specifications[idx] == '*'
            raise ArgumentError, "Can only specify one wildcard '*' in between resource specifications"
          elsif specifications[idx].is_a?(Specification)
            break
          end
        end
        true
      end
    end
    
    module InstanceMethods
      def self.included(base)
        base.class_eval do
        protected
          # we define the find|new_resource(s) methods only if they're not already defined
          # this allows abstract controllers to define the resource service methods
          unless instance_methods.include?('find_resources')
            # finds the collection of resources
            def find_resources
              resource_service.find :all
            end
          end

          unless instance_methods.include?('find_resource')
            # finds the resource, using the passed id
            def find_resource(id = params[:id])
              resource_service.find id
            end
          end

          unless instance_methods.include?('new_resource')
            # makes a new resource, optionally using the passed hash
            def new_resource(attributes = (params[resource_name] || {}))
              resource_service.new attributes
            end
          end
        end
        base.send :hide_action, *instance_methods
      end
      
      def resource_service=(service)
        @resource_service = service
      end
      
      def name_prefix
        @name_prefix ||= ''
      end
      
      # name of the singular resource
      def resource_name
        resource_specification.name
      end
      
      # name of the resource collection
      def resources_name
        @resources_name ||= resource_specification.name.pluralize
      end
      
      # returns the controller's resource class
      def resource_class
        resource_specification.klass
      end
      
      # returns the controller's current resource.
      def resource
        instance_variable_get("@#{resource_name}")
      end
      
      # sets the controller's current resource, and
      # decorates the object with a save hook, so we know if it's been saved
      def resource=(record)
        instance_variable_set("@#{resource_name}", record)
      end
  
      # returns the controller's current resources collection
      def resources
        instance_variable_get("@#{resources_name}")
      end
      
      # sets the controller's current resource collection
      def resources=(collection)
        instance_variable_set("@#{resources_name}", collection)
      end
      
      # returns the immediately enclosing resource
      def enclosing_resource
        enclosing_resources.last
      end
      
      # returns the name of the immediately enclosing resource
      def enclosing_resource_name
        @enclosing_resource_name
      end
      
      # returns the resource service for the controller - this will be lazilly created
      # to a ResourceService, or a SingletonResourceService (if :singleton => true)
      def resource_service
        @resource_service ||= resource_specification.singleton? ? SingletonResourceService.new(self) : ResourceService.new(self)
      end
      
      # returns the instance resource_specification
      def resource_specification
        self.class.resource_specification
      end
      
      # returns an array of the controller's enclosing (nested in) resources
      def enclosing_resources
        @enclosing_resources ||= []
      end
  
      # returns an array of the collection (non singleton) enclosing resources, this is used for generating routes.
      def enclosing_collection_resources
        @enclosing_collection_resources ||= []
      end
      
      # NOTE: This method is overly complicated and unecessary.  It's much clearer just to keep
      # track of record saves yourself, this is here for BC.  For an example of how it should be
      # done look at the actions module in http://github.com/ianwhite/response_for_rc
      #
      # Has the resource been saved successfully?, if no save has been attempted, save the
      # record and return the result
      #
      # This method uses the @resource_saved tracking var, or the model's state itself if
      # that is not available (which means if you do resource.update_attributes, then this
      # method will return the correct result)
      def resource_saved?
        save_resource if @resource_saved.nil? && !resource.validation_attempted?
        @resource_saved = resource.saved? if @resource_saved.nil?
        @resource_saved
      end
      
      # NOTE: it's clearer to just keep track of record saves yourself, this is here for BC
      # See the comment on #resource_saved?
      #
      # @resource_saved = resource.update_attributes(params[resource_name])
      #
      # Save the resource, and keep track of the result
      def save_resource
        @resource_saved = resource.save
      end
      
    private
      # returns the route that was used to invoke this controller and current action.  The path is found first from params[:resource_path]
      # if it exists, and then from the request.path.  Likewise the method is found from params[:resource_method]
      #
      # params[:erp] == params[:resource_path] for BC
      def recognized_route
        unless @recognized_route
          path = params[:resource_path] || params[:erp] || request.path
          environment = ::ActionController::Routing::Routes.extract_request_environment(request)
          environment.merge!(:method => params[:resource_method]) if params[:resource_method]
          @recognized_route ||= ::ActionController::Routing::Routes.routes_for_controller_and_action(controller_path, action_name).find do |route|
            route.recognize(path, environment)
          end or ResourcesController.raise_no_recognized_route(self)
        end
        @recognized_route
      end
      
      # returns the all route segments except for the ones corresponding to the current resource and action.
      # Also remove any route segments from the front which correspond to modules (namespaces)
      def enclosing_segments
        segments = remove_namespaces_from_segments(recognized_route.segments.dup)
        while segments.size > 0
          segment = segments.pop
          return segments if segment.is_a?(::ActionController::Routing::StaticSegment) && segment.value == resource_specification.segment
        end
        ResourcesController.raise_missing_segment(self)
      end
      
      # shift namespaces from segments, update the name_prefix accordingly for outgoing routes. 
      def remove_namespaces_from_segments(segments)
        namespaces = controller_path.sub(controller_name,'').sub(/\/$/,'').split('/')
        while namespaces.size > 0
          if segments[0].is_a?(ActionController::Routing::DividerSegment) && segments[1].is_a?(ActionController::Routing::StaticSegment) && segments[1].value == namespaces.first
            segments.shift; segments.shift # shift the '/' & 'namespace' segments
            update_name_prefix("#{namespaces.shift}_")
          else
            break
          end
        end
        segments
      end
      
      # Returns an array of pairs [<name>, <singleton?>] e.g. [[users, false], [blog, true], [posts, false]]
      # corresponding to the enclosing resource route segments
      #
      # This is used to map resources and automatically load resources.
      def route_enclosing_names
        @route_enclosing_names ||= returning(Array.new) do |req|
          enclosing_segments.each do |segment|
            unless segment.is_optional or segment.is_a?(::ActionController::Routing::DividerSegment)
              req << [segment.value, true] if segment.is_a?(::ActionController::Routing::StaticSegment)
              req.last[1] = false if segment.is_a?(::ActionController::Routing::DynamicSegment)
            end
          end
        end
      rescue MissingSegment
        # fallback: construct enclosing names from param ids
        @route_enclosing_names = params.keys.select{|k| k.to_s =~ /_id$/}.map{|id| [id.sub('_id','').pluralize, false]}
      end
      
      # this is the before_filter that loads all specified and wildcard resources
      def load_enclosing_resources
        specifications.each_with_index do |spec, idx|
          case spec
            when '*' then load_wildcards_from(idx)
            when /^\?(.*)/ then load_wildcard($1)
            else load_enclosing_resource_from_specification(spec)
          end
        end
      end
      
      # load a wildcard resource by either
      # * matching the segment to mapped resource specification, or
      # * creating one using the segment name
      # Optionally takes a variable name to set the instance variable as (for polymorphic use)
      def load_wildcard(as = nil)
        route_enclosing_names[enclosing_resources.size] or ResourcesController.raise_resource_mismatch(self)
        segment, singleton = *route_enclosing_names[enclosing_resources.size]
        if resource_specification_map[segment]
          spec = resource_specification_map[segment]
          spec = returning(spec.dup) {|s| s.as = as} if as
        else
          spec = Specification.new(singleton ? segment : segment.singularize, :singleton => singleton, :as => as)
        end
        load_enclosing_resource_from_specification(spec)
      end
      
      # loads a series of wildcard resources, from the specified specification idx
      #
      # To do this, we need to figure out where the next specified resource is
      # and how many single wildcards are prior to that.  What is left over from
      # the current route enclosing names will be the number of wildcards we need to load
      def load_wildcards_from(start)
        specs = specifications.slice(start..-1)
        encls = route_enclosing_names.slice(enclosing_resources.size..-1)
        
        if spec = specs.find {|s| s.is_a?(Specification)}
          spec_seg = encls.index([spec.segment, spec.singleton?]) or ResourcesController.raise_resource_mismatch(self)
          number_of_wildcards = spec_seg - (specs.index(spec) -1)
        else
          number_of_wildcards = encls.length - (specs.length - 1)
        end        

        number_of_wildcards.times { load_wildcard }
      end
         
      def load_enclosing_resource_from_specification(spec)
        spec.segment == route_enclosing_names[enclosing_resources.size].first or ResourcesController.raise_resource_mismatch(self)
        returning spec.find_from(self) do |resource|
          add_enclosing_resource(resource, :name => spec.name, :name_prefix => spec.name_prefix, :is_singleton => spec.singleton?, :as => spec.as)
        end
      end
      
      def add_enclosing_resource(resource, options = {})
        name = options[:name] || resource.class.name.underscore
        update_name_prefix(options[:name_prefix] || (options[:name_prefix] == false ? '' : "#{name}_"))
        enclosing_resources << resource
        enclosing_collection_resources << resource unless options[:is_singleton]
        instance_variable_set("@enclosing_resource_name", options[:name])
        instance_variable_set("@#{name}", resource)
        instance_variable_set("@#{options[:as]}", resource) if options[:as]
      end
      
      # The name prefix is used for forwarding urls and will be different depending on
      # which route the controller was invoked by.  The resource specifications build
      # up the name prefix as the resources are loaded.
      def update_name_prefix(name_prefix)
        @name_prefix = "#{@name_prefix}#{name_prefix}"
      end
    end
    
    # Proxy class to provide a consistent API for resource_service.  This is mostly
    # required for Singleton resources. Also allows decoration of the resource service with custom finders
    class ResourceService < Builder::BlankSlate
      attr_reader :controller
      delegate :resource_specification, :resource_class, :enclosing_resource, :to => :controller
      
      def initialize(controller)
        @controller = controller
      end
            
      def method_missing(*args, &block)
        service.send(*args, &block)
      end
      
      def find(*args, &block)
        resource_specification.find ? resource_specification.find_custom(controller) : super
      end
      
      def respond_to?(method, include_private = false)
        super || service.respond_to?(method)
      end
    
      def service
        @service ||= enclosing_resource ? enclosing_resource.send(resource_specification.source) : resource_class
      end
    end
    
    class SingletonResourceService < ResourceService
      def find(*args)
        if resource_specification.find
          resource_specification.find_custom(controller)
        elsif controller.enclosing_resources.size > 0
          enclosing_resource.send(resource_specification.source)
        else
          ResourcesController.raise_cant_find_singleton(controller.resource_name, controller.resource_class)
        end
      end

      # build association on the enclosing resource if there is one
      def new(*args)
        enclosing_resource ? enclosing_resource.send("build_#{resource_specification.source}", *args) : super
      end

      def service
        resource_class
      end
    end
    
    class CantFindSingleton < RuntimeError #:nodoc:
    end

    class MissingSegment < RuntimeError #:nodoc:
    end

    class NoRecognizedRoute < RuntimeError #:nodoc:
    end
    
    class ResourceMismatch < RuntimeError #:nodoc:
    end

    class << self
      def raise_cant_find_singleton(name, klass) #:nodoc:
        raise CantFindSingleton, <<-end_str
Can't get singleton resource from class #{klass.name}. You have have probably done something like:

  nested_in :#{name}, :singleton => true  # <= where this is the first nested_in

You should tell resources_controller how to find the singleton resource like this:

  nested_in :#{name}, :singleton => true do
    #{klass.name}.find(<.. your find args here ..>)
  end

Or: 
  nested_in :#{name}, :singleton => true, :find => <.. method name or lambda ..>

Or, you may be relying on the route to load the resource, in which case you need to give RC some
help.  Do this by mapping the route segment to a resource in the controller, or a parent or mixin

  map_enclosing_resource :#{name}, :segment => ..., :singleton => true <.. as above ..>
end_str
      end

      def raise_missing_segment(controller) #:nodoc:
        raise MissingSegment, <<-end_str
Could not recognize segment '#{controller.resource_specification.segment}' in route:
  #{controller.send(:recognized_route)}

Check that config/routes.rb defines a route named '#{controller.name_prefix}#{controller.resource_specification.singleton? ? controller.route_name : controller.route_name.pluralize}'
  for controller: #{controller.controller_name.camelize}Controller"
end_str
      end
      
      def raise_no_recognized_route(controller) #:nodoc:
        raise NoRecognizedRoute, <<-end_str
resources_controller could not recognize a route that that the controller
was invoked with.  This is probably being raised in a test.

The controller name is '#{controller.controller_name}'
The request.path is '#{controller.request.path}'
The route request environment is:
  #{::ActionController::Routing::Routes.extract_request_environment(controller.request).inspect}

Possible reasons for this:
- routes have not been loaded
- the controller has been invoked with params that don't correspond to a
  route (and so would never be invoked in a real app)
- the test can't figure out which route corresponds to the params, in this 
  case you may need to stub the recognized_route. (rspec example:)
  @controller.stub!(:recognized_route).and_return(ActionController::Routing::Routes.named_routes[:the_route])
        end_str
      end
      
      def raise_resource_mismatch(controller) #:nodoc:
        raise ResourceMismatch, <<-end_str
resources_controller can't match the route to the resource specification
  route:         #{controller.send(:recognized_route)}
  specification: enclosing: [#{controller.specifications.collect{|s| s.is_a?(Specification) ? ":#{s.segment}" : s}.join(', ')}], resource :#{controller.resource_specification.segment}
  
the successfully loaded enclosing resources are: #{controller.enclosing_resources.join(', ')}
        end_str
      end
    end
  end
end
