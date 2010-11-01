require 'yaml'
require 'erb'
require 'ostruct'

require 'rubygems'
require 'activesupport'

# = SettingsReader
#
# Reads settings from an ERB-parsed YAML file and returns an OpenStruct object.
#
# Examples:
#   # Read from default "config/settings.yml" and "config/settings-sample.yml" files:
#   SETTINGS = SettingsReader.read
#
#   # Read a specific file:
#   SETTINGS = SettingsReader.read("myfile.yml")
#
class SettingsReader
  # Return an OpenStruct object with setting information. The settings are read
  # from an ERB-parsed YAML file.
  #
  # Arguments:
  # * Filename to read settings from. Optional, if not given will try
  #   "config/setting.yml" and "config/setting-sample.yml".
  #
  # Options:
  # * :verbose => Print status to screen on error. Defaults to true.
  def self.read(*args)
    opts = args.extract_options!
    verbose = opts[:verbose] != false
    given_file = args.first

    normal_file = "config/settings.yml"
    sample_file = "config/settings-sample.yml"
    rails_root = RAILS_ROOT rescue File.dirname(File.dirname(__FILE__))

    message = "** SettingsReader - "

    if object = self.filename_to_ostruct(given_file)
      message << "loaded '#{given_file}'"
    elsif object = self.filename_to_ostruct(File.join(rails_root, normal_file))
      message << "loaded '#{normal_file}'"
    elsif object = self.filename_to_ostruct(File.join(rails_root, sample_file))
      message << "loaded '#{sample_file}'"
    else
      raise Errno::ENOENT, "Couldn't find '#{normal_file}'"
    end

    RAILS_DEFAULT_LOGGER.info(message) rescue nil

    return object
  end

  # Return an OpenStruct object by reading the +filename+ and parsing it with ERB and YAML.
  def self.filename_to_ostruct(filename)
    return OpenStruct.new(YAML.load(ERB.new(File.read(filename)).result)) rescue nil
  end
end
