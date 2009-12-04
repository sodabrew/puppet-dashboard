desc "Create database.yml from example"
task :copy_config do
  config = File.join(RAILS_ROOT, 'config', 'database.yml')
  example = config + '.example'
  FileUtils.cp(example, config) unless File.exists?(config)
end

desc "Install puppet dashboard"
task :install => [:copy_config, 'db:create', 'db:migrate', 'db:seed']
