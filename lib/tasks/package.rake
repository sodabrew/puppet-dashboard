namespace :package do
  desc "Create .deb from this git checkin, optionallyh set UNSIGNED=1 to leave unsigned."
  task :deb => :environment do
    unless ENV['FORCE'] == '1'
      modified = `git status --untracked-files=no | grep 'modified:'`
      if $?.to_i == 0
        puts <<-HERE
!! ERROR: Your git working directory contains modified files. You must
!! remove or commit your changes before you can create a package:

#{modified}

To override this check, set FORCE=1 -- e.g. `rake package:deb FORCE=1`
        HERE
        raise
      end
    end

    work = File.expand_path(File.join(RAILS_ROOT, 'tmp', 'packages'))
    build = File.join(work, 'build')

    rm_rf work
    mkdir_p work

    sh "git checkout-index -a -f --prefix=#{build}/"
    cd build do
      cp_r File.join('ext', 'packaging', 'debian'), '.'
      cp File.join(RAILS_ROOT, 'config', 'database.yml.example'), File.join('debian', 'doc', 'examples')
      cmd = 'dpkg-buildpackage -a'
      cmd << ' -us -uc' if ENV['UNSIGNED'] == '1'
      sh cmd
    end
  end
end
