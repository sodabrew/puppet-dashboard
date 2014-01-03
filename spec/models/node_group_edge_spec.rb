require 'spec_helper'

describe NodeGroupEdge do
  it {should belong_to(:to)}
  it {should belong_to(:from)}
end
