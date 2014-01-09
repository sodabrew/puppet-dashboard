source 'https://rubygems.org'

gem 'rake'                , '~> 0.9.3'
gem 'rails'               , '~> 3.2'
gem 'will_paginate'       , '~> 3.0'
gem 'inherited_resources' , '1.4.0' # Pin this until they fix ruby 1.8.7 compat

gem 'thin'
gem 'rack'

gem 'daemons'
gem 'json_pure'
gem 'safe_yaml',    :require => false
gem 'fastercsv',    :platforms => :ruby_18
gem 'system_timer', :platforms => :ruby_18

gem 'delayed_job', '~> 3.0'
gem 'delayed_job_active_record', '~> 0.3.3'
gem 'timeline_fu', '~> 0.3.0'
gem 'haml', '~> 3.1.8'

group :assets do
  gem 'sass-rails'    , '~> 3.2'
  gem 'haml-rails'    , '~> 0.3.5'
  gem 'jquery-rails'  , '~> 2.1'
  gem 'uglifier'      , '~> 1.0'
  gem 'execjs' # Will use system-available JS runtime
end

group :development, :test do
  gem 'mocha', '~> 0.13.3', :require => false
  gem 'sqlite3'
  gem 'rspec-rails', '~> 2.13.0'
  gem 'factory_girl', '< 3.0' # supports ruby 1.8.7
  gem 'shoulda-matchers', '< 2.0' # support ruby 1.8.7
  gem 'rspec-html-matchers'
  gem 'nokogiri', '< 1.6' # support ruby 1.8.7
end

group :postgresql do
  gem 'pg', '~> 0.15'
end

group :mysql do
  gem 'mysql2', '~> 0.3.11'
end
