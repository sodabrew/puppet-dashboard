require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'shared_behaviors/controller_mixins'
require 'shared_behaviors/sorted_index'

describe NodeGroupsController do
  integrate_views
  def model; NodeGroup end

  it_should_behave_like "without JSON pagination"
  it_should_behave_like "with search by q and tag"
  it_should_behave_like "sorted index"

  describe "when diffing latest inspect report against baseline and" do
    before :each do
      @node_group = NodeGroup.generate!
      @node = Node.generate! :name => "node_it_all"
      @node_group.nodes << @node

      @child_node_group = NodeGroup.generate!
      @child_node = Node.generate! :name => "nema_node"
      @child_node_group.nodes << @node

      @node_group.node_group_children << @child_node_group
    end

    describe "the node has no inspect reports" do
      it "should not produce a node diff and should keep track that there is no inspect report" do
        get :diff, :id => @node_group.id
        response.should be_success
        assigns[:nodes_without_latest_inspect_reports].should == [@node]
        assigns[:nodes_without_baselines].should be_empty
        assigns[:nodes_with_differences].should be_empty
        assigns[:nodes_without_differences].should be_empty
      end
    end

    describe "the node has inspect reports but no baseline" do
      it "should not produce a node diff and should keep track that there is no baseline" do
        Report.generate!(:host => @node.name, :kind => 'inspect', :time => 2.hours.ago)

        get :diff, :id => @node_group.id
        response.should be_success
        assigns[:nodes_without_latest_inspect_reports].should be_empty
        assigns[:nodes_without_baselines].should == [@node]
        assigns[:nodes_with_differences].should be_empty
        assigns[:nodes_without_differences].should be_empty
      end
    end

    describe "there is a baseline and latest inspect report" do
      before :each do
        @baseline = Report.generate!(:host => @node.name, :kind => 'inspect', :time => 2.hours.ago)
        @baseline_status = ResourceStatus.generate!(
          :report        => @baseline,
          :resource_type => 'File',
          :title         => '/tmp/test'
        )

        @latest = Report.generate!(:host => @node.name, :kind => 'inspect', :time => 1.hour.ago)
        @latest_status = ResourceStatus.generate!(
          :report        => @latest,
          :resource_type => 'File',
          :title         => '/tmp/test'
        )

        @node.reports = [@baseline, @latest]
        @baseline.baseline!
        @node.last_inspect_report = @latest
      end

      it "should not produce a node diff if the node doesn't have any differences" do
        @baseline_event = ResourceEvent.generate!(
          :resource_status => @baseline_status,
          :property        => 'content',
          :previous_value  => '{md5}0b8b61ed7bce7ffb93cedc19845468cc'
        )

        @latest_event = ResourceEvent.generate!(
          :resource_status => @latest_status,
          :property        => 'content',
          :previous_value  => '{md5}0b8b61ed7bce7ffb93cedc19845468cc'
        )

        get :diff, :id => @node_group.id

        response.should be_success

        assigns[:nodes_without_latest_inspect_reports].should be_empty
        assigns[:nodes_without_baselines].should be_empty
        assigns[:nodes_with_differences].should be_empty
        assigns[:nodes_without_differences].should == [@node]
      end

      it "should keep track of appropriate information when reports have differences" do
        @baseline_event_with_difference = ResourceEvent.generate!(
          :resource_status => @baseline_status,
          :property        => 'content',
          :previous_value  => '{md5}abcd'
        )

        @latest_event_with_difference = ResourceEvent.generate!(
          :resource_status => @latest_status,
          :property        => 'content',
          :previous_value  => '{md5}efgh'
        )

        get :diff, :id => @node_group.id

        response.should be_success

        assigns[:nodes_without_latest_inspect_reports].should be_empty
        assigns[:nodes_without_baselines].should be_empty
        assigns[:nodes_without_differences].should be_empty
        assigns[:nodes_with_differences].should == [ {
          :resource_statuses   => {:pass=>[], :failure=>["File[/tmp/test]"]},
          :last_inspect_report => @latest,
          :baseline_report     => @baseline,
          :report_diff         => {"File[/tmp/test]"=>{:content=>["{md5}abcd", "{md5}efgh"]}}
        }]
      end
    end
  end
end
