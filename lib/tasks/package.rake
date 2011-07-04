namespace :package do
  desc "Create .deb from this git repository, set KEY_ID=your_key to use a specific key or UNSIGNED=1 to leave unsigned."
  task :deb => :build_environment do
    build_dir = create_workspace('deb')

    cd build_dir do
      cp_r File.join('ext', 'packaging', 'debian'), '.'
      cmd = 'dpkg-buildpackage -a'
      cmd << ' -us -uc' if ENV['UNSIGNED'] == '1'
      cmd << " -k#{ENV['KEY_ID']}" if ENV['KEY_ID']

      begin
        sh cmd
        puts "** Created package: "+ latest_file(File.expand_path(File.join(RAILS_ROOT, 'tmp', 'packages', 'deb', '*.deb')))
      rescue
        puts <<-HERE
!! Building the .deb failed!
!! Perhaps you want to run:

    rake package:deb UNSIGNED=1

!! Or provide a specific key id, e.g.:

    rake package:deb KEY_ID=4BD6EC30
    rake package:deb KEY_ID=me@example.com

        HERE
      end
    end
  end

  desc "Create srpm from this git repository (unsigned)"
  task :srpm => :tar do 
    name='puppet-dashboard'
    temp=`mktemp -d`.strip!
    pwd=`pwd`.strip!
    spec_file="ext/packaging/redhat/#{name}.spec"
    rpm_defines = " --define \"_specdir #{temp}/SPECS\" --define \"_rpmdir #{temp}/RPMS\" --define \"_sourcedir #{temp}/SOURCES\" --define \" _srcrpmdir #{temp}/SRPMS\" --define \"_builddir #{temp}/BUILD\""
    sh " [ -f /usr/bin/rpmbuild ] "
    dirs = [ 'BUILD', 'SPECS', 'SOURCES', 'RPMS', 'SRPMS' ]
    dirs.each do |d|
      FileUtils.mkdir_p "#{temp}//#{d}"
    end
    sh "mv tmp/packages/tar/*.tar.gz #{temp}/SOURCES"
    sh "cp #{spec_file} #{temp}/SPECS"
    sh "rpmbuild #{rpm_defines} -bs --nodeps #{temp}/SPECS/*.spec"
    sh "mv -f #{temp}/SRPMS/* ."
    sh "rm -rf #{temp}/BUILD #{temp}/SRPMS #{temp}/RPMS #{temp}/SPECS #{temp}/SOURCES"
    sh "rm -rf #{temp}"
  end

  desc "Create .rpm from this git repository, set UNSIGNED=1 to leave unsigned."
  task :rpm => :build_environment do
    unless File.exists?(File.expand_path('~/.rpmmacros'))
      puts <<-HERE
!! You must setup a ~/.rpmmacros file.
!! You can do this by running:

    rake package:rpm:create_rpmmacros

      HERE
    end

    version = File.open('VERSION', 'r').read.sub(/^v/, '').chomp
    sh "git archive --format=tar --prefix=puppet-dashboard-#{version}/ HEAD | gzip > #{rpm_macro_value('_sourcedir')}/puppet-dashboard-#{version}.tar.gz"
    cd File.expand_path(rpm_macro_value('_specdir')) do
      cp File.join(RAILS_ROOT, 'ext', 'packaging', 'redhat', 'puppet-dashboard.spec'), 'puppet-dashboard.spec'

      cmd = 'rpmbuild -ba'
      cmd << ' --sign' unless ENV['UNSIGNED'] == '1'
      cmd << ' puppet-dashboard.spec'

      begin
        sh cmd
        puts "** Created package: "+ latest_file(File.expand_path(File.join(rpm_macro_value('_rpmdir'), 'noarch', 'puppet-dashboard*.rpm')))
      rescue
        puts <<-HERE
!! Building the '.rpm's failed!
!! Perhaps you want to run:

    rake package:rpm UNSIGNED=1
        HERE
      end
    end
  end

  namespace :rpm do
    desc "Create ~/.rpmmacros and related directories"
    task :create_rpmmacros do
      rpmmacro_file = File.expand_path("~/.rpmmacros")
      unless File.exists?(rpmmacro_file)
        rpmmacro = "
%_topdir %(echo $HOME)/rpmbuild
%_builddir %{_topdir}/BUILD
%_rpmdir %{_topdir}/RPMS
%_sourcedir %{_topdir}/SOURCES
%_specdir %{_topdir}/SPECS
%_srcrpmdir %{_topdir}/SRPMS
%_buildrootdir %{_topdir}/BUILDROOT

%buildroot %{_buildrootdir}/%{name}-%{version}-%{release}.%{_arch}
$RPM_BUILD_ROOT %{buildroot}
"
        File.open(rpmmacro_file, "w") {|f| f.write(rpmmacro)}
      end

      %w{_builddir _rpmdir _sourcedir _specdir _srcrpmdir _buildrootdir}.each do |dir|
        sh %Q|mkdir -p #{rpm_macro_value(dir)}|
      end
    end
  end

  desc "Create a release .tar.gz"
  task :tar do
    version        = File.open('VERSION', 'r').read.sub(/^v/, '').chomp
    work           = File.expand_path(File.join(RAILS_ROOT, 'tmp', 'packages', 'tar'))
    release_prefix = "puppet-dashboard-#{version}"
    release_file   = File.join work, "#{release_prefix}.tar.gz"

    mkdir_p work
    if File.exists?(release_file)
      puts <<-HERE
!! Release tar.gz file already exists: #{release_prefix}.tar.gz
!! Please move or remove this file before proceeding.
      HERE
      raise
    end

    sh %Q{git archive --format=tar --prefix=#{release_prefix}/ HEAD | gzip > "#{release_file}"}

    puts <<-HERE
Saved release to: #{release_file}
    HERE
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

  # Return the file with the latest mtime matching the String filename glob (e.g. "foo/*.bar").
  def latest_file(glob)
    require 'find'
    return FileList[glob].map{|path| [path, File.mtime(path)]}.sort_by(&:last).map(&:first).last
  end

  # Resolve an RPM macro.
  def rpm_macro_value(macro)
    `rpmbuild -E '%#{macro}' #{File.join(RAILS_ROOT, 'ext', 'packaging', 'redhat', 'puppet-dashboard.spec')} 2> /dev/null`.chomp
  end
end
