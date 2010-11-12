require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe SettingsReader do
  before :each do
    @settings_file = <<FILE
foo: bar
FILE

    @sample_file = <<FILE
foo: bob
bat: baz
FILE

    @settings_file_all = <<FILE
foo: bar
bat: man
FILE
  end

  it "should use values from settings.yml if specified, and values from settings.yml.example if not" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml"}.returns(@settings_file)
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)
    RAILS_DEFAULT_LOGGER.expects(:info).with {|msg| msg =~ /Using default values for unspecified settings "bat"/}

    SettingsReader.read.should == OpenStruct.new("foo" => "bar", "bat" => "baz")
  end

  it "should use values from settings.yml.example if settings.yml does not exist" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)
    RAILS_DEFAULT_LOGGER.expects(:info).with {|msg| msg =~ /Using default values for unspecified settings "bat" and "foo"/}

    SettingsReader.read.should == OpenStruct.new("foo" => "bob", "bat" => "baz")
  end

  it "should not output a warning if settings.yml defines all settings" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml"}.returns(@settings_file_all)
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)
    RAILS_DEFAULT_LOGGER.expects(:info).with {|msg| msg !~ /Using default values/}

    SettingsReader.read.should == OpenStruct.new("foo" => "bar", "bat" => "man")
  end
end
