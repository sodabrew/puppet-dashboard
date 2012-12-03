require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe SettingsReader do
  before :each do
    @settings_file = <<FILE
foo: bar
FILE

    @sample_file = <<FILE
foo: bob
bat: baz
daily_run_history_length: 1
FILE

    @settings_file_all = <<FILE
foo: bar
bat: man
daily_run_history_length: 1
FILE

    @settings_file_invalid_daily_run = <<FILE
daily_run_history_length: 0
FILE
  end

  it "should use values from settings.yml if specified, and values from settings.yml.example if not" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml"}.returns(@settings_file)
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)
    RAILS_DEFAULT_LOGGER.expects(:info).with {|msg| msg =~ /Using default values for unspecified settings "bat"/}

    SettingsReader.read.should == OpenStruct.new(
      "foo"                      => "bar",
      "bat"                      => "baz",
      "daily_run_history_length" => 1
    )
  end

  it "should use values from settings.yml.example if settings.yml does not exist" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)
    RAILS_DEFAULT_LOGGER.expects(:info).with {|msg| msg =~ /Using default values for unspecified settings "bat", "daily_run_history_length", and "foo"/}

    SettingsReader.read.should == OpenStruct.new(
      "foo"                      => "bob",
      "bat"                      => "baz",
      "daily_run_history_length" => 1
    )
  end

  it "should not output a warning if settings.yml defines all settings" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml"}.returns(@settings_file_all)
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)
    RAILS_DEFAULT_LOGGER.expects(:info).with {|msg| msg !~ /Using default values/}

    SettingsReader.read.should == OpenStruct.new(
      "foo"                      => "bar",
      "bat"                      => "man",
      "daily_run_history_length" => 1
    )
  end

  it "should validate that 'daily_run_history_length' is >= 1" do
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml"}.returns(@settings_file_invalid_daily_run)
    File.stubs(:read).with {|filename| File.basename(filename) == "settings.yml.example"}.returns(@sample_file)

    lambda { SettingsReader.read }.should raise_error(ArgumentError, "'daily_run_history_length' must be >= 1")
  end
end
