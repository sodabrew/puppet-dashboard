module Ardes#:nodoc:
  module ResponseForRc#:nodoc:
    # actions using response_for
    module Actions
      extend Ardes::RcResponsesModule
      
      def index
        self.resources = find_resources
      end

      response_for :index do |format|
        format.html
        format.js
        format.xml  { render :xml => resources }
      end
      
      
      def show
        self.resource = find_resource
      end
      
      def new
        self.resource = new_resource
      end

      def edit
        self.resource = find_resource
      end
      
      response_for :show, :new, :edit do |format|
        format.html
        format.js
        format.xml  { render :xml => resource }
      end
      
      
      def create
        self.resource = new_resource
        @resource_saved = resource.save
      end
      
      response_for :create do |format|
        if @resource_saved
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
      
      
      def update
        self.resource = find_resource
        @resource_saved = resource.update_attributes(params[resource_name])
      end
      
      response_for :update do |format|
        if @resource_saved
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
      
      
      def destroy
        self.resource = find_resource
        resource.destroy
      end
      
      response_for :destroy do |format|
        format.html do
          flash[:notice] = "#{resource_name.humanize} was successfully destroyed."
          redirect_to resources_url
        end
        format.js
        format.xml
      end
    end
  end
end
