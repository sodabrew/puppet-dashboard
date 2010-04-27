require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroupsController do
  describe "index when searching" do
    it "should return groups whose name matches the query" do
      included = NodeGroup.generate(:name => "queryable")
      excluded = NodeGroup.generate(:name => "excluded")
      get :index, :q => 'query'

      assigns[:node_groups].should include(included)
      assigns[:node_groups].should_not include(excluded)
    end
  end
end
