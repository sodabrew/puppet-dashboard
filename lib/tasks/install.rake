rule 'database.yml' => 'config/database.yml.example' do
  sh "cp config/database.yml.example config/database.yml"
end

desc "Create database.yml from example"
task :copy_config => ['config/database.yml']

desc "Install puppet dashboard"
task :install => [:copy_config, 'db:create', 'db:schema:load', 'db:seed']
