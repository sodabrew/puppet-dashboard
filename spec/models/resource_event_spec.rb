require 'spec_helper'

describe ResourceEvent do
  describe ResourceEvent::ValueWrapper do
    describe "#load" do
      it "should return a hash when given a yaml hash" do
        test_hash = ResourceEvent::ValueWrapper.load "---\n:test: string\n"
        test_hash.should be_a Hash
      end

      it "should return a string when given a string" do
        test_string = ResourceEvent::ValueWrapper.load "test"
        test_string.should be_a String
      end

      it "should return a string when given a string that is only special characters" do
        test_string = ResourceEvent::ValueWrapper.load "*"
        test_string.should be_a String
      end
    end
  end

  describe "#<=>" do
    [%w{alpha ensure}, %w{zeta ensure}, %w{elfin ensure}].each do |input|
      it "should sort ensure before anything else" do
        input.map {|x| ResourceEvent.new(:property => x) }.
          sort.map {|x| x.property }.should ==
          ['ensure', input.first]
      end
    end

    it "should sort anything else alphabetically" do
      %w{elfin alpha ensure zeta equipage}.map do |x|
        ResourceEvent.new(:property => x)
      end.sort.map {|x| x.property }.should ==
        %w{ensure alpha elfin equipage zeta}
    end
  end
end
