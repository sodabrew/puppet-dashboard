require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeGroupEdge do
  it {should belong_to(:to)}
  it {should belong_to(:from)}
end
