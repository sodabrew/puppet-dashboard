module Ardes#:nodoc:
  module ResourcesController
    # standard CRUD actions, with html, js and xml responses, re-written to mnake best use of resources_cotroller.
    # This helps if you're writing controllers that you want to share via mixin or inheritance.
    #
    # This module is used as the actions for the controller by default, but you can change this behaviour:
    #  
    #   resources_controller_for :foos, :actions_include => false               # don't include any actions
    #   resources_controller_for :foos, :actions_include => Some::Other::Module # use this module instead
    #
    # == Why?
    #
    # The idea is to decouple the <b>model name</b> from the action code.
    #
    # Here's how:
    #
    # === finding and making new resources
    # Instead of this:
    #   @post = Post.find(params[:id])
    #   @post = Post.new
    #   @posts = Post.find(:all)
    #
    # do this:
    #   self.resource = find_resource
    #   self.resource = new_resource
    #   self.resources = find_resources
    #
    # === referring to resources
    # Instead of this:
    #   format.xml { render :xml => @post }
    #   format.xml { render :xml => @posts }
    #   
    # do this:
    #   format.xml { render :xml => resource }
    #   format.xml { render :xml => resources }
    #
    # === urls 
    # Instead of this:
    #   redirect_to posts_url
    #   redirect_to new_post_url
    #
    # do this:
    #   redirect_to resources_url
    #   redirect_to new_resource_url
    #
    module Actions
      # GET /events
      # GET /events.xml
      def index
        self.resources = find_resources

        respond_to do |format|
          format.html # index.rhtml
          format.js
          format.xml  { render :xml => resources }
        end
      end

      # GET /events/1
      # GET /events/1.xml
      def show
        self.resource = find_resource

        respond_to do |format|
          format.html # show.erb.html
          format.js
          format.xml  { render :xml => resource }
        end
      end

      # GET /events/new
      def new
        self.resource = new_resource

        respond_to do |format|
          format.html # new.html.erb
          format.js
          format.xml  { render :xml => resource }
        end
      end

      # GET /events/1/edit
      def edit
        self.resource = find_resource
        respond_to do |format|
          format.html # edit.html.erb
          format.js
          format.xml  { render :xml => resource }
        end
      end

      # POST /events
      # POST /events.xml
      def create
        self.resource = new_resource
        
        respond_to do |format|
          if resource.save
            format.html do
              flash[:notice] = "#{resource_name.humanize} was successfully created."
              redirect_to resource_url
            end
            format.js
            format.xml  { render :xml => resource, :status => :created, :location => resource_url }
          else
            format.html { render :action => "new" }
            format.js   { render :action => "new" }
            format.xml  { render :xml => resource.errors, :status => :unprocessable_entity }
          end
        end
      end

      # PUT /events/1
      # PUT /events/1.xml
      def update
        self.resource = find_resource
        
        respond_to do |format|
          if resource.update_attributes(params[resource_name])
            format.html do
              flash[:notice] = "#{resource_name.humanize} was successfully updated."
              redirect_to resource_url
            end
            format.js
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.js   { render :action => "edit" }
            format.xml  { render :xml => resource.errors, :status => :unprocessable_entity }
          end
        end
      end

      # DELETE /events/1
      # DELETE /events/1.xml
      def destroy
        self.resource = find_resource
        resource.destroy
        respond_to do |format|
          format.html do
            flash[:notice] = "#{resource_name.humanize} was successfully destroyed."
            redirect_to resources_url
          end
          format.js
          format.xml  { head :ok }
        end
      end
    end
  end
end
