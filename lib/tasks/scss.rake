desc "Compile application.scss to STDOUT"
task :scss do
  sh "sass public/stylesheets/sass/application.scss"
end
