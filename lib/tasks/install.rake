desc "Install puppet dashboard"
task :install => ['db:create', 'db:migrate', 'db:seed']
