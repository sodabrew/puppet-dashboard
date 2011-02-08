require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe @registry do
  before :each do
    @registry = Registry.new
  end

  describe "#add_callback" do
    it "does not allow multiple callbacks with the same name" do
      @registry.add_callback(:test, :hook, "test_callback", "value1")
      lambda { @registry.add_callback(:test, :hook, "test_callback", "value2") }.should raise_error(/Cannot redefine callback/)

      callbacks = []
      @registry.each_callback(:test, :hook) do |callback|
        callbacks << callback
      end
      callbacks.should == ["value1"]
    end

    it "does not allow both a value and a block to be specified" do
      lambda { @registry.add_callback(:test, :hook, "test_callback", "inline_value") { "block_value" } }.should raise_error(/Cannot pass both a value and a block/)
      callbacks = []
      @registry.each_callback(:test, :hook) do |callback|
        callbacks << callback
      end
      callbacks.should be_empty
    end

    it "adds the given callback to the registry" do
      @registry.add_callback(:test, :hook, "0_block_callback") { "my block" }
      @registry.add_callback(:test, :hook, "1_value_callback", "foo bar baz")

      callbacks = []
      @registry.each_callback(:test, :hook) do |callback|
        callbacks << callback
      end
      callbacks.first.should be_a(Proc)
      callbacks.first.call.should == "my block"
      callbacks.last.should == "foo bar baz"
    end
  end

  describe "#each_callback" do
    it "does nothing if the hook has no callbacks" do
      callbacks = []
      @registry.each_callback(:test, :nonexistent) do |callback|
        callbacks << callback
      end
      callbacks.should be_empty
    end

    it "yields each callback in order" do
      @registry.add_callback(:test, :hook, "2_callback", "second")
      @registry.add_callback(:test, :hook, "3_callback", "third")
      @registry.add_callback(:test, :hook, "1_callback", "first")

      values = []

      @registry.each_callback(:test, :hook) do |value|
        values << value
      end

      values.should == ["first", "second", "third"]
    end

    it "yields procs intact, not their values" do
      @registry.add_callback(:test, :hook, "my_callback") { "my_callback_value" }
      @registry.add_callback(:test, :hook, "my_other_callback") { "my_other_callback_value" }

      blocks = []
      @registry.each_callback(:test, :hook) do |block|
        blocks << block
      end

      blocks.map(&:class).should == [Proc, Proc]
      blocks.map(&:call).should == ["my_callback_value", "my_other_callback_value"]
    end
  end

  describe "#find_first_callback" do
    it "returns the value returned by the first callback which returns a value" do
      @registry.add_callback(:test, :hook, "0_callback") { 0 }
      @registry.add_callback(:test, :hook, "1_callback") { 1 }
      @registry.add_callback(:test, :hook, "2_callback") { 2 }

      @registry.find_first_callback(:test, :hook) do |callback|
        val = callback.call
        val.odd? ? val.ordinalize : nil
      end.should == "1st"
    end
  end
end
