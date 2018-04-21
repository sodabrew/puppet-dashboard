Puppet Dashboard
================

Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/).
It can view and analyze Puppet reports, assign Puppet classes and parameters to
nodes, and view inventory data and backed-up file contents.

Dependencies
------------

* Ruby 1.8.7, 1.9.3 or 2.0.0
* Bundler >= 1.1
* MySQL >= 5.1 or PostgreSQL >= 9.0

Fast Install
------------

* Check out the code or download a release package.
* Create a MySQL database and user, and set `max_allowed_packet` to 32M.
* Edit your `config/settings.yml` and `config/database.yml` files.
* `gem install bundler`
* `bundle install --deployment`
* Generate a new secret_token in config/settings.yml:
  `echo "secret_token: '$(bundle exec rake secret)'" >> config/settings.yml`
* `bundle exec rake db:setup`
* `bundle exec rails server`
* Set up Puppet to be Dashboard-aware.
* Start the delayed job worker processes.

Production Environment
----------------------

Dashboard is currently configured to serve static assets when `RAILS_ENV=production`. In high-traffic
environments, you may wish to farm this out to Apache or nginx.  Additionally, you must explicitly
precompile assets for production using:

 * `RAILS_ENV=production bundle exec rake assets:precompile`

Contributing
------------

To contribute to this project, please read [CONTRIBUTING](CONTRIBUTING.md).  
A list of contributors is found in [CONTRIBUTORS](CONTRIBUTORS.md). Thanks!  
This project uses the [Silk icons](http://www.famfamfam.com/lab/icons/silk/) by Mark James.  Thank you!
