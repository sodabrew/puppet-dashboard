require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Parameter do
  before { @parameter = Parameter.generate! }

  it { should belong_to(:parameterable) }
  it { should validate_presence_of(:key) }

  it "serializes values" do
    @parameter.value = [1,2,3]
    @parameter.save
    Parameter.find(@parameter.id).value.should == [1,2,3]
  end
end
