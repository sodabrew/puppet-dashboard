require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

class TestNormalizeNames
  include NormalizeNames
end

describe NormalizeNames, "when included in a class" do
  it 'should add a normalize_names method to instances of that class' do
    TestNormalizeNames.new.should respond_to(:normalize_name)
  end

  describe 'when calling normalize_name on an instance of a class which includes NormalizeNames' do
    before :each do
      @obj = TestNormalizeNames.new
    end

    it 'should accept a string' do
      lambda { @obj.normalize_name('foo') }.should_not raise_error(ArgumentError)
    end

    it 'should require a string' do
      lambda { @obj.normalize_name }.should raise_error(ArgumentError)
    end

    it 'should not be empty' do
      @obj.normalize_name('foo').should_not be_empty
    end

    it 'should return a string with only letters, numbers, and underscores' do
      @obj.normalize_name('!@#$^%&*()12344567890qwertyQWERTY?[]=._').should_not match(/[^a-zA-Z0-9_]/)
    end

    it 'should return a string with no uppercase letters' do
      @obj.normalize_name('This is A String').should_not match(/[A-Z]/)
    end

    it 'should return a string without multiple adjacent underscores' do
      @obj.normalize_name('How about this   ____ !!!!! Buddy?').should_not match(/__/)
    end

    it 'should return a string with no leading underscores' do
      @obj.normalize_name('!!!!Wazzzup').should_not match(/^_/)
    end

    it 'should return a string with no trailing underscores' do
      @obj.normalize_name('Wazzzup!!!!').should_not match(/_$/)
    end

    it 'should return something, even for a completely degenerate string' do
      @obj.normalize_name('_________').should_not be_empty
    end
  end
end
