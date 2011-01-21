require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StringHelper do
  describe ".is_md5?" do
    it "returns true for a valid md5" do
      helper.is_md5?("abcdef0123456789abcdef0123456789").should == true
    end

    it "returns false for a value that is too short" do
      helper.is_md5?("abcdef0123456789").should == false
    end

    it "returns false for a value that is too long" do
      helper.is_md5?("abcdef012345678abcdef01234567899abcdef0123456789").should == false
    end

    it "returns false for a value that contains illegal characters" do
      helper.is_md5?("this is not an md5").should == false
    end

    it "returns false for upper-case values" do
      helper.is_md5?("ABCDEF0123456789ABCDEF0123456789").should == false
    end
  end
end
