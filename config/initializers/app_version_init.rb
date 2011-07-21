# Get the Dashboard version number.
#
# Any officially released package or tarball of dashboard
# will have a VERSION file that is generated at tarball
# build time.
#
# This allows for the APP_VERSION to be determined by git, so
# developers can run out of master after a git checkout.
def get_app_version
  if File.exists?(Rails.root.join('VERSION'))
    return File.read(Rails.root.join('VERSION')).strip
  elsif File.directory?(Rails.root.join('.git'))
    return `cd '#{Rails.root}'; git describe`.strip! rescue 'unknown'
  end

  'unknown'
end

APP_VERSION = get_app_version
