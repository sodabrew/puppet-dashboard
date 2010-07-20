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

1. Download the Puppet Dashboard software, all the following instructions
    assume that you're running commands from the directory containing this source
    code, which has this `README.markdown` file:

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

4. Populate the database with the tables for the Puppet Dashboard:

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
   the Puppet Dashboard software containing this `README.markdown` file before
   running these commands:

    1. Start a `production` server on port 3000:

           ./script/server -e production

    2. Or start a `development` server on port 8080, where the `development`
        environment is used by default:

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
   [Thin](http://code.macournoyer.com/thin/).

Reporting
---------

### Import existing reports into the Puppet Dashboard

To import Puppet run reports stored in `/var/puppet/lib/reports` into your
`production` environment:

    rake RAILS_ENV=production reports:import

Or specify a different report directory:

    rake RAILS_ENV=production reports:import REPORT_DIR=/path/to/your/reports

You can re-run these commands, the importer will skip existing reports and
won't create duplicate entries.

### Import reports from your puppetmasterd as they're produced

#### Puppet 0.25.x and earlier

To enable live report aggregation, you will need to modify your puppetmaster and puppet clients.

Make your clients send reports to the puppetmaster by setting `report` to
`true` in the `[puppetd]` block of your `puppet.conf`, e.g.:

    [puppetd]
    report=true

Then modify your puppetmaster:

1. The custom reporting library will assume that your Puppet Dashboard server is
    running on `localhost` at port `3000`, which is the default if started
    using `script/server`. If you need to specify different values, edit the
    settings in Puppet Dashboard's `lib/puppet/puppet_dashboard.rb` file.

2. Identify your puppetmaster's `libdir` by running the following command, it
    will probably be `/var/lib/puppet`:

        puppetmasterd --configprint libdir

3. Create a directory for custom report libraries, e.g. run the following
    command, but replace `LIBDIR` with the path you found in step 2:

        mkdir -p LIBDIR/lib/puppet/reports/

2. Copy or symlink the Puppet Dashboard's report library in, e.g. run the
    following command from your Puppet Dashboard's checkout directory, but
    replace `LIBDIR` with the path you found in step 2:

        ln sf $PWD/lib/puppet/puppet_dashboard.rb LIBDIR/lib/puppet/reports

4. Ensure that your puppetmasterd runs successfully with the option:

        --reports puppet_dashboard

#### Puppet 2.6.x

For newer versions of Puppet, a new `http` reports processor has been added
that will send reports to a server located at `http://localhost:3000/reports`.
To enable the `http` processor, add it to the `reports` setting in your
`puppet.conf`. The url can be configured via the `reporturl` setting in your
`puppet.conf`.

For example, a `puppet.conf` for sending reports to a Puppet Dashboard server
running on `localhost` at port `3000` may look like:

    [server]
    reports=http
    reporturl=http://localhost:3000/reports

    [agent]
    report=true

*Note:* The `reporturl` above is the default. You only need to specify a `reporturl` if you host Dashboard at some other url. Also note that the `puppet.conf` block name changed in 2.6.x from `[puppetd]` to `[agent]`.

Using as an external node classification tool
---------------------------------------------

The Puppet Dashboard functions as an external node classification tool. All
nodes can be exported as Puppet-compatible YAML. See `bin/external_node` for an
example script that connects to the Puppet Dashboard as an external node
classifier. The tool assumes that the Puppet Dashboard is running on
`localhost` at port `3000`. Please modify the `bin/external_node` constants if
you need different settings.

Contributors
------------

* Rein Henrichs <reinh@reinh.com>
* Igal Koshevoy <igal@pragmaticraft.com>
* Rick Bradley <rick@rickbradley.com>
* Andrew Maier <andrew.maier@gatech.edu>
* Scott Smith <scott@ohlol.net>
* Ian Ward Comfort <icomfort@stanford.edu>
