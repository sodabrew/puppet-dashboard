Puppet Dashboard
================

Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/).
It can view and analyze Puppet reports, assign Puppet classes and parameters to
nodes, and view inventory data and backed-up file contents.

Dependencies
------------

* Ruby 2.2, 2.3, 2.4, 2.5
* MySQL/MariaDB >= 5.5 or PostgreSQL >= 9.2

Puppet Report Format Support
----------------------------

[Puppet Format Documentation](https://github.com/puppetlabs/puppet-docs/tree/master/source/_includes/reportformat)

| Format Version  | Puppet Version | Dashboard Version |
|-----------------|----------------|-------------------|
| 0               | 0.25.x         | >= 1.0.0          |
| 1               | 2.6.0 - 2.6.4  | >= 1.0.0          |
| 2               | 2.6.5 - 2.7.11 | >= 1.0.0          |
| 3               | 2.7.13 - 3.2.4 | >= 1.0.0          |
| 4               | 3.3.0 - 4.3.2  | >= 2.0.0          |
| 5               | 4.4.0 - 4.5.3  | >= 3.0.0          |
| 6               | 4.6.0 - 4.10.x | >= 3.0.0          |
| 7               | 5.0.0 - 5.3.x  | >= 3.0.0          |
| 8               | 5.4.0 - 5.4.x  | >= 3.0.0          |
| 9               | 5.5.0 - 5.5.x  | >= 3.0.0          |

Future Puppet Report formats may work automatically if no required fields are removed.
If there is a new Format available which is not yet supported please let us know by creating
a [new issue](https://github.com/sodabrew/puppet-dashboard/issues/new).

Fast Install
------------

* Install prerequisites:
````
apt-get install git libmysqlclient-dev libpq-dev libsqlite3-dev ruby-dev libxml2-dev libxslt-dev nodejs
````
* Check out the code:
````
cd /usr/share && \
git clone https://github.com/sodabrew/puppet-dashboard.git && \
cd puppet-dashboard
````
* Create a MySQL database and user
````
mysql -p -e"CREATE DATABASE dashboard_production CHARACTER SET utf8;" && \
mysql -p -e"CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'my_password';" && \
mysql -p -e"GRANT ALL PRIVILEGES ON dashboard_production.* TO 'dashboard'@'localhost';"
````
* Set `max_allowed_packet = 32M` in your MySQL configuration
````
vim /etc/mysql/my.cnf
````
* Edit your `config/settings.yml` and `config/database.yml` files.
````
cp config/settings.yml.example config/settings.yml && \
cp config/database.yml.example config/database.yml && \
vim config/database.yml
````
* Install Puppet Dashboard Dependencies
````
gem install bundler && \
bundle install --deployment
````
* You need to create a secret for production and either set it via environment variable:
  `export SECRET_KEY_BASE=$(bundle exec rails secret)`
  or follow the instructions in config/secrets.yml to setup an encrypted secret. 
* Setup database and pre-compile assets
````
RAILS_ENV=production bundle exec rake db:setup && \
RAILS_ENV=production bundle exec rake assets:precompile
````
* Start Puppet Dashboard manually
````
RAILS_ENV=production bundle exec rails server
````
* Set up Puppet to be Dashboard-aware.
* Start the delayed job worker processes.
* You will find an initscript and other useful files for Debian in `ext/debian`

Production Environment
----------------------

Dashboard is currently configured to serve static assets when `RAILS_ENV=production`. In high-traffic
environments, you may wish to farm this out to Apache or nginx.  Additionally, you must explicitly
precompile assets for production using:

 * `SECRET_KEY_BASE=none RAILS_ENV=production bundle exec rails assets:precompile`

Contributing
------------

To contribute to this project, please read [CONTRIBUTING](CONTRIBUTING.md).  
A list of contributors is found in [CONTRIBUTORS](CONTRIBUTORS.md). Thanks!  
This project uses the [Silk icons](http://www.famfamfam.com/lab/icons/silk/) by Mark James.  Thank you!
