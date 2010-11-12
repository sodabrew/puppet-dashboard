require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe SettingsReader do
  before :each do
    @settings_file = <<FILE
foo: bar
FILE

    @sample_file = <<FILE
bat: baz
FILE
  end

  it "should use settings.yml if it exists" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml"}.returns(@settings_file)
    File.stubs(:read).with {|filename| File.basename(filename) == "settings-sample.yml"}.returns(@sample_file)

    SettingsReader.read.should == OpenStruct.new("foo" => "bar")
  end

  it "should use settings-sample.yml if settings.yml does not exist" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings-sample.yml"}.returns(@sample_file)

    SettingsReader.read.should == OpenStruct.new("bat" => "baz")
  end
end
