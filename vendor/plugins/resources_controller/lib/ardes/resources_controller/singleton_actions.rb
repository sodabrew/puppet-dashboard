module Ardes#:nodoc:
  module ResourcesController
    module SingletonActions
      include Actions
      
      undef index

      # DELETE /event
      # DELETE /event.xml
      def destroy
        self.resource = find_resource
        resource.destroy
        respond_to do |format|
          format.html do
            flash[:notice] = "#{resource_name.humanize} was successfully destroyed."
            redirect_to enclosing_resource_url if enclosing_resource
          end
          format.js
          format.xml  { head :ok }
        end
      end
    end
  end
end
