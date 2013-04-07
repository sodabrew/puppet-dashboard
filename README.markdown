Puppet Dashboard
================

Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/).
It can view and analyze Puppet reports, assign Puppet classes and parameters to
nodes, and view inventory data and backed-up file contents.

For full documentation, see the [Puppet Dashboard 1.2 Manual](http://docs.puppetlabs.com/dashboard/manual/1.2).

Rails 3 Branch
--------------

This is the Rails 3 branch of Puppet Dashboard. A great number of changes are
on this branch vs. the mainline PD 1.2.x / Rails 2 branch. A short summary:

* Update to Rails 3.2, Bundler 1.x, rspec 2, and many other gems.
* Update jQuery to 1.8.
* Use Rails mass-assignment protection.
* Remove Prototype JS.

Dependencies
------------

* Ruby 1.8.7
* Bundler >= 1.1
* MySQL >= 5.1

Fast Install
------------

* Check out the code.
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

For detailed installation, setup, and usage instructions, see the [Puppet Dashboard 1.2 Manual](http://docs.puppetlabs.com/dashboard/manual/1.2).

Production Environment
----------------------

Dashboard is currently configured to serve static assets when `RAILS_ENV=production`. In high-traffic
environments, you may wish to farm this out to Apache or nginx.  Additionally, you must explicitly
precompile assets for production using:
 * `RAILS_ENV=production bundle exec rake assets:precompile` 


Icons
-----

Puppet Dashboard uses Mark James' fine [Silk icons](http://www.famfamfam.com/lab/icons/silk/).

Thanks, Mark!

Contributing
------------

To contribute to this project, please read [CONTRIBUTING](CONTRIBUTING.md).
A list of contributors is found in [CONTRIBUTORS](CONTRIBUTORS.md). Thanks!
