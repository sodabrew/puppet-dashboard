# Get the Dashboard version number.

APP_VERSION = File.read(Rails.root.join('VERSION')).strip.sub(/^v/, '')
