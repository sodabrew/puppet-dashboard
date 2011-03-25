namespace :reports do
  namespace :samples do
    desc "Generate sample YAML reports and import them into the database"
    task :populate => [:generate, 'reports:import'] 
  end
end
