require 'spec_helper'

describe NodeGroupClassMembership do
  it { should belong_to(:node_class) }
  it { should belong_to(:node_group) }
end
