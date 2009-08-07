require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Ardes::ResponseFor::VERSION do
  it "STRING should be 0.3.1" do
    Ardes::ResponseFor::VERSION::STRING.should == '0.3.1'
  end
end