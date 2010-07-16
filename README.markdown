Puppet Dashboard
================

Overview
--------

The Puppet Dashboard is a web interface providing node classification and
reporting features for [Puppet](http://www.puppetlabs.com/), an open source
system configuration management tool.

Source, community and support
-----------------------------

* [Puppet Dashboard source code](http://github.com/reductivelabs/puppet-dashboard)
* [Puppet Dashboard issue tracker](http://projects.puppetlabs.com/projects/dashboard)
* [Puppet Dashboard mailing list](http://groups.google.com/group/puppet-dashboard)
* [Puppet users mailing list](http://groups.google.com/group/puppet-users)

Dependencies
------------

The Puppet Dashboard will run on most Unix, Linux and Mac OS X systems if you
install the following software from your operating system's repositories or
these websites:

* [Ruby](http://www.ruby-lang.org/en/downloads/) or [Ruby Enterprise
  Edition](http://www.rubyenterpriseedition.com/download.html) programming
  language interpreter, version 1.8.4 to 1.8.7, but not 1.9.x
* [Rake](http://github.com/jimweirich/rake) build tool for Ruby, version 0.8.3
  or newer
* [MySQL](http://www.mysql.com/downloads/mysql/) database server 5.x
* [Ruby-MySQL](http://rubygems.org/gems/mysql) bindings 2.8.x

You may also want to install these tools:

* [Git](http://git-scm.com/) revision control system to checkout the source code
* [Rubygems](http://rubygems.org/) package manager to easily install Ruby libraries

Installation
------------

1. Download the Puppet Dashboard software:

    1. Checkout the latest source code using Git:

           git clone git://github.com/reductivelabs/puppet-dashboard.git

    2. Or install the software using APT or RPM packages. See
       `README_PACKAGES.markdown` for instructions.

2. Setup a MySQL database server, create a user and database for use with the
   Dashboard. For example, you might start a `mysql` session as `root` and run
   commands like:

        CREATE DATABASE dashboard CHARACTER SET utf8;
        CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'my_password';
        GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';

3. Create a `config/database.yml` file to connect your Puppet Dashboard to this
   new database. Please see the `config/database.yml.example` file for further
   details about database configurations and environments.

4. Populate the database with the tables for the Puppet Dashboard. You must
   `cd` into the directory with the Puppet Dashboard software before running
   these commands:

    1. For typical use with the `production` environment:

           rake RAILS_ENV=production db:migrate

    2. For developing the software using the `development` and `test`
       environments:

           rake db:migrate db:test:prepare

Running
-------

There are many ways to run a Ruby web application like the Puppet Dashboard, we
recommend:

1. **Built-in webserver**: You can run a single instance of the application
   without any additional software. This is great for getting started quickly,
   but isn't recommended for production use because it's slow and can't handle
   multiple requests at the same time. You must `cd` into the directory with
   the Puppet Dashboard software before running these commands:

    1. Start a `production` server on port 3000:

           ./script/server -e production

    2. Or start a `development` server on port 8080:

           ./script/server -p 8080

2. **Passenger**: You can compile this plugin for
   [Apache](http://httpd.apache.org/) or [Nginx](http://nginx.org/) to easily
   serve Ruby web apps quickly and with multiple instances -- it's great for
   production use. You can also use it with Ruby Enterprise Edition to reduce
   memory usage. For further information, please see
   [Passenger/](http://www.modrails.com/) and [Ruby Enterprise
   Edition](http://www.rubyenterpriseedition.com/) and the example apache
   configuration in `ext/passenger/dashboard-vhost.conf`.

3. **Thin**: You can install this server, have it start multiple instances of
   your application as a cluster, and then put it behind a proxy like
   [Apache](http://httpd.apache.org/) or [Nginx](http://nginx.org/) -- it's
   fast and reliable. For further information, please see
   [Thin](http://code.macournoyer.com/thin/)

Reporting
---------

### Import existing reports into the Puppet Dashboard

To import Puppet run reports stored in `/var/puppet/lib/reports` to your
`production` environment:

    rake RAILS_ENV=production reports:import

Or specify a different report directory:

    rake RAILS_ENV=production reports:import REPORT_DIR=/path/to/your/reports

### Import reports from your puppetmasterd as they're produced

First, ensure that your puppet agents are sending reports to the puppet server by setting `report` to true in the `[agents]` block of your `puppet.conf`.

#### Puppet 0.25.x and earlier

To enable live report aggregation, add the absolute path to the Puppet
Dashboard's `lib/puppet` directory to your `puppet.conf` file's `libdir`.

For example, if you installed the Puppet Dashboard into `/opt/puppet-dashboard`
and your regular `libdir` was `/var/puppet/lib`, you would add a line to your
`puppet.conf` like:

    libdir = /opt/puppet-dashboard/lib/puppet:/var/puppet/lib

To verify that this change was valid, run this command and confirm that it
printed what you just set:

    puppet --configprint libdir

Then ensure that your puppetmasterd runs with the option `--reports
puppet_dashboard`.

The `puppet_dashboard` report assumes that your Puppet Dashboard server is
available at `localhost` on port 3000 (as it would be if you started it via
`script/server`). For now, you will need to modify the constants in
`lib/puppet/puppet_dashboard.rb` if this is not the case.

#### Puppet 2.6.x

For the latest Puppet, a new `http` reports processor has been added that will
send reports to a server located at `http://localhost:3000/reports`. To enable the `http`
processor, add it to the `reports` setting in your `puppet.conf`. The url can
be configured via the `reporturl` setting in your `puppet.conf`.

A complete `puppet.conf` example for reporting to a Puppet Dashboard server running under Passenger on port 81:

    [server]
    reporturl=http://localhost:81/reports
    reports=http

    [agent]
    report=true

Using as an external node classification tool
---------------------------------------------

The Puppet Dashboard functions as an external node classification tool. All
nodes can be exported as Puppet-compatible YAML. See `bin/external_node` for an
example script that connects to the Puppet Dashboard as an external node
classifier.

Contributors
------------

* Rein Henrichs <reinh@reinh.com>
* Igal Koshevoy <igal@pragmaticraft.com>
* Rick Bradley <rick@rickbradley.com>
* Andrew Maier <andrew.maier@gatech.edu>
* Scott Smith <scott@ohlol.net>
* Ian Ward Comfort <icomfort@stanford.edu>
