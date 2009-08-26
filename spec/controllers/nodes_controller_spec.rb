require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodesController, 'when integrating' do
  integrate_views

  before :each do
    @node = Node.generate!
  end

  describe 'index' do
    def do_request
      get :index
    end

    it_should_behave_like "a successful action"
  end

  describe 'new' do
    def do_request
      get :new
    end

    it_should_behave_like "a successful action"
  end

  describe 'show' do
    def do_request
      get :show, :id => @node.id.to_s
    end
      
    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @node.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @node = Node.spawn
    end

    def do_request
      post :create, :node => @node.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @node.id.to_s, :node => @node.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @node.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
  
  describe 'disconnect' do
    before :each do
      @service = Service.generate!
    end
    
    def do_request
      get :disconnect, :id => @node.id.to_s, :service_id => @service.id.to_s
    end
    
    it_should_behave_like "an embeddable action"
  end

  
  describe 'connect' do
    before :each do
      @service = Service.generate!
    end
    
    def do_request
      get :connect, :id => @node.id.to_s, :service_id => @service.id.to_s
    end
    
    it_should_behave_like "an embeddable action"
  end
end

describe NodesController, 'when not integrating' do  
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a create action'
  it_should_behave_like 'a RESTful controller with a destroy action'
  
  describe '#show, when YAML is requested' do
    before :each do
      @parameters = { 'a' => 'b', 'c' => 'd' }
      @node = Node.generate!(:parameters => @parameters)
      @services = Array.new(3) { Service.generate! }
      @node.services << @services
    end
    
    def do_get  
      @request.env["HTTP_ACCEPT"] = "application/x-yaml" 
      get :show, :id => @node.id.to_s
    end
    
    it 'should return a YAML result' do
      do_get
      response.headers['Content-Type'].should match(/^application\/x-yaml/)
    end
    
    it 'should not use a layout' do
      do_get
      response.layout.should be_nil
    end

    it 'should return the node configuration as the YAML result' do
      do_get
      response.body.should == @node.configuration.to_yaml
    end
  end
  
  describe '#edit' do
    before :each do
      @node = Node.generate!
    end
    
    def do_get
      get :edit, :id => @node.id.to_s
    end
    
    it 'should make the requested node available to the view' do
      do_get
      assigns[:node].should == @node
    end
    
    it 'should make the list of available services available to the view' do
      @services = Array.new(6) { Service.generate! }
      @node.services << @services[0..2]
      do_get
      assigns[:available_services].should == @services[3..5]
    end
    
    it 'should render the edit template' do
      do_get
      response.should render_template('edit')
    end
    
    it 'should use the default layout' do
      do_get
      response.layout.should == 'layouts/application'
    end
  end
  
  describe '#update' do
    before :each do
      @node = Node.generate!
      @params = { :id => @node.id.to_s, :node => @node.attributes }
    end
    
    def do_put
      put :update, @params
    end
    
    it 'should fail when an invalid node id is given' do
      @params[:id] = (@node.id+100).to_s
      lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
    end
    
    describe 'when a valid node id is given' do

      describe 'and the data provided would make the node invalid' do
        before :each do
          @params[:node]['name'] = nil
        end
        
        it 'should make the node available to the view' do
          do_put
          assigns[:node].should == @node
        end
        
        it 'should not save the node' do
          do_put
          Node.find(@node.id).name.should_not be_nil
        end
        
        it 'should have errors on the node' do
          do_put
          assigns[:node].errors[:name].should_not be_blank
        end
        
        it 'should render the edit action' do
          do_put
          response.should render_template('edit')
        end
        
        it 'should use the default layout' do
          do_put
          response.layout.should == 'layouts/application'       
        end
      end
      
      describe 'and the data provided make the node valid' do
        it 'should note the update success in flash' do
          do_put
          flash[:notice].should match(/success/i)
        end
        
        it 'should update the node with the data provided' do
          @params[:node]['name'] = 'new name'
          do_put
          Node.find(@node.id).name.should == 'new name' 
        end
        
        it 'should redirect to the show action for the node' do
          do_put
          response.should redirect_to(node_path(@node))
        end
        
        it 'should set the parameters to an empty hash when the data provides no empty parameters list' do
          @params[:node].delete('parameters')
          do_put
          Node.find(@node.id).parameters.should == {}
        end
        
        it 'should set the parameters to an empty hash when the data provides an empty parameters list' do
          @params[:node]['parameters'] = {}
          do_put
          Node.find(@node.id).parameters.should == {}
        end
        
        it 'should set the parameters to an empty hash when the data provides no non-blank parameter names' do
          @params[:node]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
          do_put
          Node.find(@node.id).parameters.should == {}          
        end
        
        it 'should set the parameters to a hash based on the data keys and values' do
          @params[:node]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
          do_put
          Node.find(@node.id).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
        end
      end
    end
  end

  describe 'connect' do
    before :each do
      @node = Node.generate!
      @service = Service.generate!
      @params = { :id => @node.id.to_s, :service_id => @service.id.to_s }
    end
    
    def do_get
      get :connect, @params
    end
    
    it 'should fail when no service id is provided' do
      @params.delete(:service_id)
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should fail when no node id is provided' do
      @params.delete(:id)
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should fail when an invalid service id is provided' do
      @params[:service_id] = @service.id + 100
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should fail when an invalid node is provided' do
      @params[:id] = @node.id + 100
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should add the requested service to the service list for the node' do
      do_get
      @node.services.should include(@service)
    end
    
    it 'should show the connect view' do
      do_get
      response.should render_template('connect')
    end
    
    it 'should not use a layout' do
      do_get
      response.layout.should be_nil
    end
  end
  
  describe 'disconnect' do
    before :each do
      @node = Node.generate!
      @service = Service.generate!
      @params = { :id => @node.id.to_s, :service_id => @service.id.to_s }
      @node.services << @service
    end
    
    def do_get
      get :disconnect, @params
    end
    
    it 'should fail when no service id is provided' do
      @params.delete(:service_id)
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should fail when no node id is provided' do
      @params.delete(:id)
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should fail when an invalid service id is provided' do
      @params[:service_id] = @service.id + 100
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should fail when an invalid node is provided' do
      @params[:id] = @node.id + 100
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)      
    end
    
    it 'should remove the requested service from the service list for the node' do
      do_get
      @node.services.should_not include(@service)
    end
    
    it 'should show the disconnect view' do
      do_get
      response.should render_template('disconnect')
    end
    
    it 'should not use a layout' do
      do_get
      response.layout.should be_nil
    end
  end
end
