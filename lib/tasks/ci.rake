desc "Prep CI RSpec tests"
task :ci_prep do
    require 'rubygems'
    begin
        gem 'ci_reporter'
        require 'ci/reporter/rake/rspec'
        ENV['CI_REPORTS'] = 'results'
    rescue LoadError
       puts 'Missing ci_reporter gem. You must have the ci_reporter gem installed to run the CI spec tests'
    end 
end
