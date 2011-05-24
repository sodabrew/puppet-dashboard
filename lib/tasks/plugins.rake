namespace :puppet do
  namespace :plugin do
    desc "Copy the migrations from a Puppet plugin into db/migrate"
    task :copy_migration do
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
    end

    desc "Install a Dashboard plug-in"
    task :install => [:create_installed_semaphore, :copy_migration, "db:migrate"]

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
