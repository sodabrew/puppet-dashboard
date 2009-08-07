require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

module ErrorInTemplateSpec
  class AController < ActionController::Base
    self.view_paths = [File.join(File.dirname(__FILE__), '../fixtures/views')]
    
    response_for :action_rendering_erroneous_template do |format|
      format.html { render :action => 'error_in_template' }
    end
  end

  describe AController do
    integrate_views
    
    it "GET :action_rendering_erroneous_template should raise \"Boom!\"" do
      lambda { get :action_rendering_erroneous_template }.should raise_error("Boom!")
    end
  end
end