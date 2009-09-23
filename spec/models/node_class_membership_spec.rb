require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeClassMembership do
  it { should belong_to(:node) }
  it { should belong_to(:node_class) }
end
