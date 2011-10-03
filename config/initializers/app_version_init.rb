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

def get_app_version_link
  if File.exists?(Rails.root.join('VERSION_LINK'))
    return File.read(Rails.root.join('VERSION_LINK')).strip
  else
    return "https://github.com/puppetlabs/puppet-dashboard/blob/#{APP_VERSION.sub(/.*?g([0-9a-f]*)/, "\\1")}/CHANGELOG"
  end
end

APP_VERSION = get_app_version
APP_VERSION_LINK = get_app_version_link
