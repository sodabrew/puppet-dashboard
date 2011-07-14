require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResourceEvent do
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
