# This shared behavior file provides two routing specification functions:
# 
# 1. a simple (default) RESTful controller
# 1. a simple (default) +nested+ RESTful controller
#
# In order to use the first form, the only thing that it requires is that
# the describe contain the controller constant. Controller name, params,
# and URLs are all derived from this. It will not work if you stray from
# the base resource in routes.rb.
# Example,
#
#   describe MyController, 'routing' do
#     it_should_behave_like 'a RESTful controller with routes'
#   end
#
# In order to use the second form, it shares the requirement of the first,
# the describe contain the controller constant. It also require that you
# set a @parent_controller instance variable, which is just the name.
# Example,
#
#   describe MyNestedController, 'routing' do
#     before :each do
#       @parent_controller = 'employers'
#     end
#     it_should_behave_like 'a nested RESTful controller with routes'
#   end

def controller_name
  @controller_name ||= controller.class.to_s.sub('Controller', '').underscore
end

def base_url
  @base_url ||= "/#{controller_name}"
end

def base_params
  @base_params ||= {:controller => controller_name}
end

shared_examples_for 'a RESTful controller with routes' do
  it "should map :action => 'index' to /\#{controller_name}" do
    route_for(base_params.merge(:action => 'index')).should == base_url
  end

  it "should map :action => 'show', :id => '1' to /\#{controller_name}/1" do
    route_for(base_params.merge(:action => 'show', :id => '1')).should == "#{base_url}/1"
  end
  
  it "should map :action => 'new' to /\#{controller_name}/new" do
    route_for(base_params.merge(:action => 'new')).should == "#{base_url}/new"
  end

  it "should map :action => 'create' to /\#{controller_name}" do
    route_for(base_params.merge(:action => 'create')).should == { :path => base_url, :method => 'post' }
  end

  it "should map :action => 'edit', :id => '1' to /\#{controller_name}/1/edit" do
    route_for(base_params.merge(:action => 'edit', :id => '1')).should == "#{base_url}/1/edit"
  end

  it "should map :action => 'update', :id => '1' to /\#{controller_name}/1" do
    route_for(base_params.merge(:action => 'update', :id => '1')).should == {:path => "#{base_url}/1", :method => 'put' }
  end

  it "should map :action => 'destroy', :id => '1' to /\#{controller_name}/1" do
    route_for(base_params.merge(:action => 'destroy', :id => '1')).should == {:path => "#{base_url}/1", :method => 'delete' }
  end
  
  it "should build params :action => 'index' from GET /\#{controller_name}" do
    params_from(:get, base_url).should == base_params.merge(:action => 'index')
  end
  
  it "should build params :action => 'show', :id => '1' from GET /\#{controller_name}/1" do
    params_from(:get, "#{base_url}/1").should == base_params.merge(:action => 'show', :id => '1')
  end

  it "should build params :action => 'new' from GET /\#{controller_name}/new" do
    params_from(:get, "#{base_url}/new").should == base_params.merge(:action => 'new')
  end

  it "should build params :action => 'create' from POST /\#{controller_name}" do
    params_from(:post, base_url).should == base_params.merge(:action => 'create')
  end

  it "should build params :action => 'edit', :id => '1' from GET /\#{controller_name}/1/edit" do
    params_from(:get, "#{base_url}/1/edit").should == base_params.merge(:action => 'edit', :id => '1')
  end

  it "should build params :action => 'update', :id => '1' from PUT /\#{controller_name}/1" do
    params_from(:put, "#{base_url}/1").should == base_params.merge(:action => 'update', :id => '1')
  end

  it "should build params :action => 'destroy', :id => '1' from DELETE /\#{controller_name}/1" do
    params_from(:delete, "#{base_url}/1").should == base_params.merge(:action => 'destroy', :id => '1')
  end
end

# for basic nested routes
def parent_controller_name
  @parent_controller
end

def parent_url
  @parent_url ||= "/#{parent_controller_name}/1"
end

def nested_url
  @base_nested_url ||= parent_url + base_url
end

def nested_params
  @nested_params ||= base_params.merge("#{parent_controller_name.singularize}_id".to_sym => '1')
end

shared_examples_for 'a nested RESTful controller with routes' do    
  it "should map :parent_id => '1', :action => 'index' to /\#{parent_controller_name}/1/\#{controller_name}" do
    route_for(nested_params.merge(:action => 'index')).should == nested_url
  end

  it "should map :parent_id => '1', :action => 'show', :id => '1' to /\#{parent_controller_name}/1/\#{controller_name}/1" do
    route_for(nested_params.merge(:action => 'show', :id => '1')).should == "#{nested_url}/1"
  end
  
  it "should map :parent_id => '1', :action => 'new' to /\#{parent_controller_name}/1/\#{controller_name}/new" do
    route_for(nested_params.merge(:action => 'new')).should == "#{nested_url}/new"
  end

  it "should map :parent_id => '1', :action => 'create' to /\#{parent_controller_name}/1/\#{controller_name}" do
    route_for(nested_params.merge(:action => 'create')).should == nested_url
  end

  it "should map :parent_id => '1', :action => 'edit', :id => '1' to /\#{parent_controller_name}/1/\#{controller_name}/1/edit" do
    route_for(nested_params.merge(:action => 'edit', :id => '1')).should == "#{nested_url}/1/edit"
  end

  it "should map :parent_id => '1', :action => 'update', :id => '1' to /\#{parent_controller_name}/1/\#{controller_name}/1" do
    route_for(nested_params.merge(:action => 'update', :id => '1')).should == "#{nested_url}/1"
  end

  it "should map :parent_id => '1', :action => 'destroy', :id => '1' to /\#{parent_controller_name}/1/\#{controller_name}/1" do
    route_for(nested_params.merge(:action => 'destroy', :id => '1')).should == "#{nested_url}/1"
  end
  
  it "should build params :parent_id => '1', :action => 'index' from GET /\#{parent_controller_name}/1/\#{controller_name}" do
    params_from(:get, nested_url).should == nested_params.merge(:action => 'index')
  end

  it "should build params :parent_id => '1', :action => 'show', :id => '1' from GET /\#{parent_controller_name}/1/\#{controller_name}/1" do
    params_from(:get, "#{nested_url}/1").should == nested_params.merge(:action => 'show', :id => '1')
  end

  it "should build params :parent_id => '1', :action => 'new' from GET /\#{parent_controller_name}/1/\#{controller_name}/new" do
    params_from(:get, "#{nested_url}/new").should == nested_params.merge(:action => 'new')
  end

  it "should build params :parent_id => '1', :action => 'create' from POST /\#{parent_controller_name}/1/\#{controller_name}" do
    params_from(:post, nested_url).should == nested_params.merge(:action => 'create')
  end

  it "should build params :parent_id => '1', :action => 'edit', :id => '1' from GET /\#{parent_controller_name}/1/\#{controller_name}/1/edit" do
    params_from(:get, "#{nested_url}/1/edit").should == nested_params.merge(:action => 'edit', :id => '1')
  end

  it "should build params :parent_id => '1', :action => 'update', :id => '1' from PUT /\#{parent_controller_name}/1/\#{controller_name}/1" do
    params_from(:put, "#{nested_url}/1").should == nested_params.merge(:action => 'update', :id => '1')
  end

  it "should build params :parent_id => '1', :action => 'destroy', :id => '1' from DELETE /\#{parent_controller_name}/1/\#{controller_name}/1" do
    params_from(:delete, "#{nested_url}/1").should == nested_params.merge(:action => 'destroy', :id => '1')
  end
end
