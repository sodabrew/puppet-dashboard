require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeClass do
  it { should validate_presence_of(:name) }

  ["with spaces", "invalid ch*r"].each do |name|
    it { should_not allow_value(name).for(:name) }
  end

  ["alpha", "alpha123", "namespaced::class", "hypen-name" ].each do |name|
    it { should allow_value(name).for(:name) }
  end
end
