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

  desc "Create .rpm from this git repository."
  task :rpm => [:environment, :build_environment] do
    unless File.exists?(File.expand_path('~/.rpmmacros'))
      puts <<-HERE
!! You must setup a ~/.rpmmacros file.
!! You can do this by running:

    rake package:rpm:create_rpmmacros

      HERE
    end

    version = File.open('VERSION', 'r').read.sub(/^v/, '').chomp
    sh "git archive --format=tar --prefix=puppet-dashboard-#{version}/ HEAD | gzip > ~/rpmbuild/SOURCES/puppet-dashboard-#{version}.tar.gz"
    cd File.expand_path("~/rpmbuild/SPECS") do
      cp File.join(RAILS_ROOT, 'ext', 'packaging', 'redhat', 'puppet-dashboard.spec'), 'puppet-dashboard.spec'

      cmd = 'rpmbuild -ba'
      cmd << ' --sign' unless ENV['UNSIGNED'] == '1'
      cmd << ' puppet-dashboard.spec'
      sh cmd
    end
  end

  namespace :rpm do
    desc "Create ~/.rpmmacros and related directories"
    task :create_rpmmacros do
      rpmmacro_file = File.expand_path("~/.rpmmacros")
      unless File.exists?(rpmmacro_file)
        rpmmacro = "
%{_topdir} #{File.expand_path("~/rpmbuild")}
%{_builddir} %{_topdir}/BUILD
%{_rpmdir} %{_topdir}/RPMS
%{_sourcedir} %{_topdir}/SOURCES
%{_specdir} %{_topdir}/SPECS
%{_srcrpmdir} %{_topdir}/SRPMS
%{_buildrootdir} %{_topdir}/BUILDROOT

%{buildroot} %{_buildrootdir}/%{name}-%{version}-%{release}.%{_arch}
$RPM_BUILD_ROOT %{buildroot}
"
        File.open(rpmmacro_file, "w") {|f| f.write(rpmmacro)}
      end

      %w{builddir rpmdir sourcedir specdir srcrpmdir buildrootdir}.each do |dir|
        sh %Q|mkdir -p $(rpmbuild -E '%{_#{dir}}' #{File.join(RAILS_ROOT, 'ext', 'packaging', 'redhat', 'puppet-dashboard.spec')} 2> /dev/null)|
      end
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
