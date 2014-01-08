require 'spec_helper'
require 'shared_behaviors/controller_mixins'
require 'shared_behaviors/sorted_index'

describe NodeGroupsController do
  render_views
  def model; NodeGroup end

  it_should_behave_like "without JSON pagination"
  it_should_behave_like "with search by q and tag"
  it_should_behave_like "sorted index"

  describe "#create" do
    it "should create a node group on successful creation" do
      post :create, 'node_group' => { 'name' => 'foo' }
      assigns[:node_group].name.should == 'foo'
    end

    it "should render error when creation fails" do
      post :create, 'node_group' => { }
      response.should render_template('shared/_error')
      response.should be_success

      assigns[:node_group].errors.full_messages.should == ["Name can't be blank"]
      assigns[:class_data].should include({:class=>"#node_class_ids", :data_source=>"/node_classes.json", :objects=>[]})
      assigns[:group_data].should include({:class=>"#node_group_ids", :data_source=>"/node_groups.json", :objects=>[]})
    end
  end

  describe "#new" do
    it "should successfully render the new page" do
      get :new

      response.should render_template('node_groups/new')
      response.should be_success
      assigns[:class_data].should include({:class=>"#node_class_ids", :data_source=>"/node_classes.json", :objects=>[]})
      assigns[:group_data].should include({:class=>"#node_group_ids", :data_source=>"/node_groups.json", :objects=>[]})
    end
  end

  describe "#edit" do
    before :each do
      @node_group = NodeGroup.generate!
    end

    it "should render the edit template" do
      get :edit, :id => @node_group
      assigns[:node_group].should == @node_group

      response.should render_template('edit')
      response.should be_success

      assigns[:class_data].should include({:class=>"#node_class_ids", :data_source=>"/node_classes.json", :objects=>[]})
      assigns[:group_data].should include({:class=>"#node_group_ids", :data_source=>"/node_groups.json", :objects=>[]})
    end
  end

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

        @node_group.reload.parameters.to_hash.should include({'foo' => 'bar'})
      end

      it "should allow specification of node classes" do
        node_class = NodeClass.generate!
        @params[:node_group].merge! :node_class_ids => [node_class.id]

        do_put

        @node_group.reload.node_classes.should == [node_class]
      end

      it "should be able to remove assigned classes" do
        node_class = NodeClass.generate!
        @node_group.node_classes << node_class
        @node_group.save!
        @node_group.reload.node_classes.should == [node_class]

        @params[:node_group].merge! :assigned_node_class_ids => []

        do_put

        @node_group.reload.node_classes.should be_empty
      end

      it "should be able to remove assigned groups" do
        node_subgroup = NodeGroup.generate!
        @node_group.node_groups << node_subgroup
        @node_group.save!
        @node_group.reload.node_groups.should == [node_subgroup]

        @params[:node_group].merge! :assigned_node_group_ids => []

        do_put

        @node_group.reload.node_groups.should be_empty
      end

      it "should be able to remove assigned nodes" do
        node = Node.generate!
        @node_group.nodes << node
        @node_group.save!
        @node_group.reload.nodes.should == [node]

        @params[:node_group].merge! :assigned_node_ids => []

        do_put

        @node_group.reload.nodes.should be_empty
      end
    end

    describe "when node classification is disabled" do
      before :each do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
      end

      it "should fail if parameter_attributes are specified" do
        @params[:node_group].merge! :parameter_attributes => [{:key => 'foo', :value => 'bar'}]

        do_put

        response.should be_forbidden
        response.body.should =~ /Node classification has been disabled/

        @node_group.reload.parameters.to_hash.should_not be_present
      end

      it "should fail if node classes are specified" do
        node_class = NodeClass.generate!
        @params[:node_group].merge! :assigned_node_class_ids => [node_class.id]

        do_put

        response.should be_forbidden
        response.body.should =~ /Node classification has been disabled/

        @node_group.reload.node_classes.should_not be_present
      end

      it "should succeed if parameter_attributes and node classes are omitted" do
        do_put
        response.code.should == '200'
        response_hash = JSON.parse(response.body)
        response_hash["status"].should == "ok"
        response_hash["valid"].should == "true"
        response_hash["redirect_to"].should_not be_empty
      end
    end
  end
end
