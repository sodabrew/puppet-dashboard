Puppet Dashboard
================

Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/).
It can view and analyze Puppet reports, assign Puppet classes and parameters to
nodes, and view inventory data and backed-up file contents.

For full documentation, see the [Puppet Dashboard Manual](http://docs.puppetlabs.com/dashboard/manual).

Dependencies
------------

* Ruby 1.8.7 or 1.9.3
* Bundler >= 1.1
* MySQL >= 5.1 or PostgreSQL >= 9.0

Fast Install
------------

* Check out the code or download a release package.
* Create a MySQL database and user, and set `max_allowed_packet` to 32M.
* Edit your `config/settings.yml` and `config/database.yml` files.
* `gem install bundler`
* `bundle install --path vendor/bundle`
* Generate a new secret_token in config/settings.yml:
  `echo "secret_token: '$(bundle exec rake secret)'" >> config/settings.yml`
* `bundle exec rake db:setup`
* `bundle exec rails server`
* Set up Puppet to be Dashboard-aware.
* Start the delayed job worker processes.

Icons
-----

Puppet Dashboard uses Mark James' fine [Silk icons](http://www.famfamfam.com/lab/icons/silk/).

Thanks, Mark!

Contributing
------------

To contribute to this project, please read [CONTRIBUTING](puppet-dashboard/blob/rails3/CONTRIBUTING.md).
A list of contributors is found in [CONTRIBUTORS](puppet-dashboard/blob/rails3/CONTRIBUTORS.md). Thanks!
