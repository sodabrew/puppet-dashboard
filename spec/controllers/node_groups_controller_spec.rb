require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'shared_behaviors/controller_mixins'
require 'shared_behaviors/sorted_index'

describe NodeGroupsController do
  integrate_views
  def model; NodeGroup end

  it_should_behave_like "without JSON pagination"
  it_should_behave_like "with search by q and tag"
  it_should_behave_like "sorted index"

  describe "#update" do
    def do_put
      put :update, @params
    end

    before :each do
      SETTINGS.stubs(:enable_read_only_mode).returns(false)
      @node_group = NodeGroup.generate!
      @params = { :id => @node_group.id, :node_group => {} }
    end

    describe "when node classification is enabled" do
      before :each do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
      end

      it "should allow specification of 'parameter_attributes'" do
        @params[:node_group].merge! :parameter_attributes => [{:key => 'foo', :value => 'bar'}]

        do_put

        @node_group.reload.parameters.to_hash.should == {'foo' => 'bar'}
      end

      it "should allow specification of node classes" do
        node_class = NodeClass.generate!
        @params[:node_group].merge! :node_class_ids => [node_class.id]

        do_put

        @node_group.reload.node_classes.should == [node_class]
      end
    end

    describe "when node classification is disabled" do
      before :each do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
      end

      it "should fail if parameter_attributes are specified" do
        @params[:node_group].merge! :parameter_attributes => [{:key => 'foo', :value => 'bar'}]

        do_put

        response.code.should == '403'
        response.body.should =~ /Node classification has been disabled/

        @node_group.reload.parameters.to_hash.should_not be_present
      end

      it "should fail if node classes are specified" do
        node_class = NodeClass.generate!
        @params[:node_group].merge! :node_class_ids => [node_class.id]

        do_put

        response.code.should == '403'
        response.body.should =~ /Node classification has been disabled/

        @node_group.reload.node_classes.should_not be_present
      end

      it "should succeed if parameter_attributes and node classes are omitted" do
        do_put

        response.should be_redirect
      end
    end
  end
end
