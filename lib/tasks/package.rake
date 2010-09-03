namespace :package do
  desc "Create .deb from this git repository, optionallyh set UNSIGNED=1 to leave unsigned."
  task :deb => [:environment, :build_environment] do
    build_dir = create_workspace('deb')

    cd build_dir do
      cp_r File.join('ext', 'packaging', 'debian'), '.'
      cp File.join(RAILS_ROOT, 'config', 'database.yml.example'), File.join('debian', 'doc', 'examples')
      cmd = 'dpkg-buildpackage -a'
      cmd << ' -us -uc' if ENV['UNSIGNED'] == '1'
      sh cmd
    end
  end

  task :build_environment do
    unless ENV['FORCE'] == '1'
      modified = `git status --porcelain | sed -e '/^\?/d'`
      if modified.split(/\n/).length != 0
        puts <<-HERE
!! ERROR: Your git working directory is not clean. You must
!! remove or commit your changes before you can create a package:

#{`git status | grep '^#'`.chomp}

!! To override this check, set FORCE=1 -- e.g. `rake package:deb FORCE=1`
        HERE
        raise
      end
    end
  end

  def create_workspace(package_type)
    work = File.expand_path(File.join(RAILS_ROOT, 'tmp', 'packages', package_type))
    build = File.join(work, 'build')

    rm_rf work
    mkdir_p work

    sh "git checkout-index -a -f --prefix=#{build}/"

    return build
  end
end
