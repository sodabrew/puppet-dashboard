require 'spec_helper'

describe NodeClassMembership, :type => :model do
  it { should belong_to(:node) }
  it { should belong_to(:node_class) }
end
