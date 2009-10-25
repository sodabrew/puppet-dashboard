require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroup do
  before { @node_group = NodeGroup.spawn }
  it { should have_many(:node_classes).through(:node_group_class_memberships) }


  it 'should allow setting and retrieving parameter values' do
    @node_group.parameters = { :foo => 'bar' }
    @node_group.parameters[:foo].should == 'bar'
  end

  it 'should preserve parameters as a hash across saving' do
    @node_group = NodeGroup.generate!(:parameters => { :foo => 'bar'})
    NodeGroup.find(@node_group.id).parameters[:foo].should == 'bar'
  end
end
