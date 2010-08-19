require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeClass do
  it { should validate_presence_of(:name) }

  ["", "with spaces", "invalid ch*r", "CAPS", "single:colon", "::beginswithcolon", "endswithcolons::", "1numfirst"].each do |name|
    it { should_not allow_value(name).for(:name) }
  end

  ["a", "alpha", "alpha123", "namespaced::class", "more::n2ame::sp-ace", "hypen-name" ].each do |name|
    it { should allow_value(name).for(:name) }
  end
end
