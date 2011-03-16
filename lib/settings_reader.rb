require 'yaml'
require 'erb'
require 'ostruct'

require 'rubygems'
require 'active_support'

# = SettingsReader
#
# Reads settings from an ERB-parsed YAML file and returns an OpenStruct object.
#
# Examples:
#   # Read from default "config/settings.yml" and "config/settings.yml.example" files:
#   SETTINGS = SettingsReader.read
class SettingsReader
  # Return an OpenStruct object with setting information. The settings are read
  # from an ERB-parsed YAML file.
  def self.read
    normal_file = "config/settings.yml"
    sample_file = "config/settings.yml.example"
    rails_root = RAILS_ROOT rescue File.dirname(File.dirname(__FILE__))

    message = "** SettingsReader - "

    message << "Loading settings from file #{normal_file}. "

    settings = self.filename_to_hash(File.join(rails_root, normal_file))
    defaults = self.filename_to_hash(File.join(rails_root, sample_file))

    unspecified_keys = []

    defaults.each do |key,value|
      unless settings.key?(key)
        unspecified_keys << key
        settings[key] = value
      end
    end

    if unspecified_keys.present?
      message << "Using default values for unspecified settings " << unspecified_keys.sort.map(&:inspect).to_sentence
    end

    RAILS_DEFAULT_LOGGER.info(message) rescue nil

    validate(settings)

    return OpenStruct.new(settings)
  end

  def self.default_settings
    rails_root = RAILS_ROOT rescue File.dirname(File.dirname(__FILE__))
    OpenStruct.new(self.filename_to_hash(File.join(rails_root, "config/settings.yml.example")))
  end

  # Return an OpenStruct object by reading the +filename+ and parsing it with ERB and YAML.
  def self.filename_to_hash(filename)
    return YAML.load(ERB.new(File.read(filename)).result) rescue {}
  end

  def self.validate(settings)
    raise ArgumentError.new("'daily_run_history_length' must be >= 1") unless settings['daily_run_history_length'].to_i >= 1
  end
end
