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
        if File.basename(source_file) =~ /^([0-9]+)_(.*)$/
          timestamp, migration_name = $1, $2
          # Downcase and replace anything not lower case letter, number or
          # underscore (ie -, $, ^, space, etc) with underscores
          new_migration_name = "#{timestamp}_plugin__#{plugin_name}__#{migration_name}".downcase.gsub(/[^a-z0-9_]/, '_')
          destination_file = "db/migrate/#{new_migration_name}"
          FileUtils.cp source_file, destination_file
        end
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
