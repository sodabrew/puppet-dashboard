require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'shared_behaviors/controller_mixins'

describe NodeGroupMembershipsController do
  describe "#create" do
    integrate_views

    it "should accept a node id and group id and make a membership" do
      node = Node.generate!
      group = NodeGroup.generate!

      post :create, :node_group_membership => {:node_id => node.id, :node_group_id => group.id}, :format => 'json'

      NodeGroupMembership.count.should == 1

      response.should be_success
      membership = NodeGroupMembership.first
      membership.node_id.should == node.id
      membership.node_group_id.should == group.id
    end

    it "should not create duplicate memberships" do
      node = Node.generate!
      group = NodeGroup.generate!
      membership = NodeGroupMembership.create!(:node => node, :node_group => group)

      post :create, :node_group_membership => {:node_id => node.id, :node_group_id => group.id}, :format => 'json'

      response.should_not be_success
      NodeGroupMembership.count.should == 1
      NodeGroupMembership.first.should == membership
    end

    it "should be able to create a membership using node and group names" do
      node = Node.generate!
      group = NodeGroup.generate!

      post :create, :node_name => node.name, :group_name => group.name, :format => 'json'

      response.should be_success
      NodeGroupMembership.count.should == 1
      membership = NodeGroupMembership.first
      membership.node_id.should == node.id
      membership.node_group_id.should == group.id
    end

    it "should fail if given a non-existent node name" do
      group = NodeGroup.generate!

      post :create, :node_name => "missing", :group_name => group.name, :format => 'json'

      response.should_not be_success
      NodeGroupMembership.count.should == 0
    end
  end
end
