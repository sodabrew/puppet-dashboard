require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  before(:each) do
    @valid_attributes = {
      :node_id => 1,
      :contents => "value for contents"
    }
  end

  it "should create a new instance given valid attributes" do
    Report.create!(@valid_attributes)
  end
end
