require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodeClass do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    NodeClass.create!(@valid_attributes)
  end
end
