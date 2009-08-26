require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NodesController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should map nested disconnect under services" do
    route_for(:controller => "nodes", :action => "disconnect", :service_id => '1', :id => '2').should == "/services/1/nodes/2/disconnect"
  end
  
  it "should generate params for disconnect nested under services" do
    params_from(:get, "/services/1/nodes/2/disconnect").should == {:controller => "nodes", :action => "disconnect", :service_id => "1", :id => '2'}
  end
  
  it "should map nested connect under services" do
    route_for(:controller => "nodes", :action => "connect", :service_id => '1', :id => '2').should == "/services/1/nodes/2/connect"
  end
  
  it "should generate params for connect nested under services" do
    params_from(:get, "/services/1/nodes/2/connect").should == {:controller => "nodes", :action => "connect", :service_id => "1", :id => '2'}
  end  
end
