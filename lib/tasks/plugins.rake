require 'pathname'
require 'ftools'

namespace :puppet do
  namespace :plugin do
    def link_contents(source_dir, target_dir)
      source_dir.children.each do |source_file|
        target_file = Pathname.new(target_dir + source_file.basename)

        if source_file.directory?
          target_file.mkdir unless target_file.exist?
          link_contents(source_file, target_file)
        else
          target_file.unlink if target_file.exist?
          File.copy(source_file, target_file)
        end
      end
    end

    desc "Copy the migrations from a Puppet plugin into db/migrate"
    task :stage do
      unless plugin_name = ENV['PLUGIN']
        raise "Must specify a plugin name using PLUGIN=..."
      end
      plugin_dir = File.join(Dir.pwd, 'vendor', 'plugins', plugin_name)
      unless File.exists?(plugin_dir)
        raise "Plugin #{plugin_name} not found in vendor/plugins."
      end

      Dir.glob(File.join(plugin_dir, 'db', 'migrate', '*.rb')) do |source_file|
        base_file_name = File.basename(source_file)

        unless base_file_name.match(/^\d{14}_plugin_#{plugin_name}_.+\.rb$/)
          raise "Found a misnamed migration: #{source_file}\n" +
            "Migrations for this plugin must be named in the form: YYYYMMDDHHMMSS_plugin_#{plugin_name}_*.rb"
        end

        FileUtils.cp source_file, "db/migrate/#{base_file_name}"
      end

      source_dir = Pathname.new(File.join(plugin_dir, 'public'))
      dest_dir   = Pathname.new(File.join(Rails.root, 'public'))
      link_contents(source_dir, dest_dir) if source_dir.directory?
    end

    desc "Install a Dashboard plug-in"
    task :install => [:create_installed_semaphore, :stage, "db:migrate"]

    desc "Create the semaphore file to indicate that a plugin is installed"
    task :create_installed_semaphore do
      unless plugin_name = ENV['PLUGIN']
        raise "Must specify a plugin name using PLUGIN=..."
      end
      semaphore_file_name = "config/installed_plugins/#{plugin_name}"
      FileUtils.mkdir_p('config/installed_plugins')
      File.open(semaphore_file_name, 'w') do |file_handle| end
    end

    desc "Uninstall a Dashboard plug-in"
    task :uninstall do
      unless plugin_name = ENV['PLUGIN']
        raise "Must specify a plugin name using PLUGIN=..."
      end
      semaphore_file_name = "config/installed_plugins/#{plugin_name}"
      FileUtils.rm semaphore_file_name
    end
  end
end
