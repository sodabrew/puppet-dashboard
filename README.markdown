Puppet Dashboard
================

Overview
--------

The Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/), an open source system configuration management tool. The Puppet Dashboard currently displays reports with the detailed status and history of Puppet-managed servers (nodes), and can assign Puppet classes and parameters to them.

Source, community and support
-----------------------------

* [Puppet Dashboard source code](http://github.com/puppetlabs/puppet-dashboard)
* [Puppet Dashboard issue tracker](http://projects.puppetlabs.com/projects/dashboard)
* [Puppet Dashboard mailing list](http://groups.google.com/group/puppet-dashboard)
* [Puppet users mailing list](http://groups.google.com/group/puppet-users)

Dependencies
------------

The Puppet Dashboard will run on most Unix, Linux and Mac OS X systems once its dependencies are installed from either the operating system's repositories or their respective websites. For installation instructions on specific operating systems, see below. A list of dependencies follows:

* [Ruby](http://www.ruby-lang.org/en/downloads/) or [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/download.html) programming language interpreter, version 1.8.4 to 1.8.7, but not 1.9.x
* [Rake](http://github.com/jimweirich/rake) build tool for Ruby, version 0.8.3 or newer
* [MySQL](http://www.mysql.com/downloads/mysql/) database server 5.x
* [Ruby-MySQL](http://rubygems.org/gems/mysql) bindings 2.7.x or 2.8.x
* [Rubygems](http://rubygems.org/) package manager to easily install Ruby libraries

### Operating system-specific examples for installing dependencies

*IMPORTANT*: The following example instructions assume a fresh install of their respective operating systems. Your actual installation procedure may be different depending on your system's current configuration. All commands must be run from an `sh`-compatible shell (such as `bash`, `dash` or `zsh`), unless otherwise noted.

#### Ubuntu 10.04 LTS

1.  Install the operating system packages:

        apt-get install -y build-essential irb libmysql-ruby libmysqlclient-dev \
          libopenssl-ruby libreadline-ruby mysql-server rake rdoc ri ruby ruby-dev

2.  Install the `gem` package manager, using the following shell script -- do not use the `rubygems` packaged with the operating system:

        (
          URL="http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz"
          PACKAGE=$(echo $URL | sed "s/\.[^\.]*$//; s/^.*\///")

          cd $(mktemp -d /tmp/install_rubygems.XXXXXXXXXX) && \
          wget -c -t10 -T20 -q $URL && \
          tar xfz $PACKAGE.tgz && \
          cd $PACKAGE && \
          sudo ruby setup.rb
        )

3.  Create `gem` as an alternative name for the `gem1.8` command:

        update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.8 1

#### CentOS 5.5

1. Install the [Extra Packages for Enterprise Linux (EPEL)](http://fedoraproject.org/wiki/EPEL) repository for `yum`.  Please see [the EPEL Wiki](https://fedoraproject.org/wiki/EPEL/FAQ#howtouse) for specific instructions.

2.  Install the operating system packages:

        yum install -y mysql mysql-devel mysql-server ruby ruby-devel ruby-irb \
          ruby-mysql ruby-rdoc ruby-ri

3.  Start MySQL and make it start automatically at boot:

        service mysqld start
        chkconfig mysqld on

4.  Install the `gem` package manager, using the following shell script -- do not install RubyGems version 1.3.6 or newer because they are incompatible with the version of Ruby shipped with CentOS 5.5:

        (
          URL="http://production.cf.rubygems.org/rubygems/rubygems-1.3.5.tgz"
          PACKAGE=$(echo $URL | sed "s/\.[^\.]*$//; s/^.*\///")

          cd $(mktemp -d /tmp/install_rubygems.XXXXXXXXXX) && \
          wget -c -t10 -T20 -q $URL && \
          tar xfz $PACKAGE.tgz && \
          cd $PACKAGE && \
          sudo ruby setup.rb
        )

5.  Install the `rake` gem:

        gem install rake

Installation
------------

1.  Download the Puppet Dashboard software using one of the following methods:

    1.  Install the software using APT or RPM packages. See `README_PACKAGES.markdown` for instructions.  This should be the easiest option for upgrading between stable versions as they are released.

    2.  Checkout the latest source code using the [Git](http://git-scm.com/) revision control system.  Please be aware that the initial checkout will be at the head of development, so may not be as well tested as the most recently tagged and released version.  If you want to do development and submit code for dashboard this is probably what you want, but may not be suitable for running your production environment.  The git checkout command below will checkout the most recently tagged and stable version, which isn't necessary if you really want to test or develop against the bleeding edge code.

            git clone git://github.com/puppetlabs/puppet-dashboard.git
            cd puppet-dashboard
            git checkout v1.0.4

    3.  Download the most recent release of Puppet Dashboard, extract it and move it to your install location (this may be different on your system).  This options makes upgrading more difficult since you'll have to manually manage files when upgrading, but may be a good option if you want to avoid repository setup or using git and just want to try out dashboard.

           wget --no-check-certificate https://github.com/puppetlabs/puppet-dashboard/tarball/v1.0.4 
           tar -xzvf puppetlabs-puppet-dashboard-v1.0.4-0-g071acf4.tar.gz
           mv puppetlabs-puppet-dashboard-071acf4 /usr/share/puppet-dashboard


2.  Create a `config/database.yml` file to specify Puppet Dashboard's database configuration. Please see the `config/database.yml.example` file for further details about database configurations and environments. These files paths are relative to the path of the Puppet Dashboard software containing this `README.markdown` file.

3.  Setup a MySQL database server, create a user and database for use with the Puppet Dashboard by either:

    1.  Using a `rake` task to create just the database from settings in the `config/database.yml` file. You must `cd` into the directory with the Puppet Dashboard software containing this `README.markdown` file before running these commands:

            rake RAILS_ENV=production db:create

    2.  Or creating the database, user and privileges manually by running `mysql` as a privileged user (e.g. `root`) and executing commands like:

            CREATE DATABASE dashboard CHARACTER SET utf8;
            CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'my_password';
            GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';

4.  Populate the database with the tables for the Puppet Dashboard.

    1.  For typical use with the `production` environment:

            rake RAILS_ENV=production db:migrate

    2.  For developing the software using the `development` and `test` environments:

            rake db:migrate db:test:prepare

Ownership and permission requirements
-------------------------------------

The Puppet Dashboard application requires that its files and directories have specific ownership and permissions.  Puppet Dashboard should **not** be run as `root`.

The same user that will run the application should own all the files, for example:

    sudo chown -R DASHBOARD_USER:DASHBOARD_GROUP /dashboard/location

Your Puppet Dashboard location will be wherever you cloned the source to, or if you install using a package will probably be `/usr/share/puppet-dashboard`

Upgrading
---------

### Code

The Puppet Dashboard's code is constantly improving, and whether you're following along with the edge of the source code or using deployed packages, you can benefit from upgrading periodically for new features and bug fixes.

#### Git

If you installed the code from source and you want to run the latest code, from the Puppet Dashboard source directory you can run:

    git pull

If you prefer to run a specific version of Puppet Dashboard you can checkout a specific tag, where TAG_NAME is the name of the `git` tag to use.

    git fetch
    git checkout TAG_NAME

And you can list the tag names with:

    git fetch
    git tag

#### Packages

If you installed from a package, your package management system should be able to upgrade the code for you.  See `README_PACKAGES.markdown` for more information.

### Database Schema

The Puppet Dashboard's database schema changes as features are added and improved, and you need to update it after an upgrade. You may want to backup your database before you do this — see the ‘Database backups' section of this documentation for further details.

Regardless of how you installed the code, you need to run the database migrations to update your database schema. Run this command from the installation directory as the same user that you use to run Puppet Dashboard:

    RAILS_ENV=production rake db:migrate

After upgrading the code and running the migrations, you'll need to restart your Puppet Dashboard server for these changes to take effect, which may require restarting your webserver.

Running
-------

There are many ways to run a Ruby web application like the Puppet Dashboard, we recommend:

1.  **Built-in webserver**: Ruby includes a built-in webserver that can run a single instance of the Puppet Dashboard application without any additional software. This is great for getting started quickly, but isn't recommended for production use because it's slow and can't handle multiple requests at the same time. You must `cd` into the directory with the Puppet Dashboard software containing this `README.markdown` file before running these commands:

    1.  Start a `production` server on port 3000:

            ./script/server -e production

    2.  Or start a `development` server on port 8080, where the `development` environment is used by default:

            ./script/server -p 8080

2.  **Passenger**: This plugin for [Apache](http://httpd.apache.org/) or [Nginx](http://nginx.org/) makes it easy to run multiple Ruby web apps quickly and efficiently using multiple instances -- it's great for production use. If used along with Ruby Enterprise Edition, it can dramatically reduce the memory required to run Ruby web applications. For further information, including installation and configuration instructions please see [Passenger/](http://www.modrails.com/) and [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/) and the example apache configuration in `ext/passenger/dashboard-vhost.conf`.

You will need to change the Passenger path depending on the version of Passenger you have installed. Also, DocumentRoot, ServerName, and Directory must be changed to match your Puppet Dashboard install directory.

3.  **Thin**: This fast and reliable server can run multiple instances of the Puppet Dashboard application behind a proxy like [Apache](http://httpd.apache.org/) or [Nginx](http://nginx.org/) to appear as a single website -- it's great for production use. For further information, please see [Thin](http://code.macournoyer.com/thin/).

Reporting
---------

### Import existing reports

To import Puppet reports stored in `/var/puppet/lib/reports` into your Puppet Dashboard's `production` environment:

    rake RAILS_ENV=production reports:import

Or from another report directory:

    rake RAILS_ENV=production reports:import REPORT_DIR=/path/to/your/reports

You can re-run these commands, the importer will automatically skip existing reports and won't create duplicate entries.

### Live report aggregation

The Puppet Dashboard can collect reports from your Puppet Master as they're created. To do this, you must modify your Puppet Master and all of your Puppet clients. The instructions for configuring this are different depending on what version of Puppet you are using:

#### Puppet 0.25.x and earlier

##### On your clients

1.  Make your clients send reports by setting `report` to `true` in the `[puppetd]` block of your `puppet.conf`, e.g.:

        [puppetd]
          report = true

##### On your Puppet Master

1.  Identify your Puppet Master's `libdir` by running the following command, it will probably be `/var/lib/puppet`:

        puppetmasterd --configprint libdir

2.  If a puppet agent is also running on the puppet master:

    a. Determine if the puppet agent is using pluginsync.  You can find this out by running the following command:

        puppetd --configprint pluginsync

    b. If the value of pluginsync is true, you will need to ensure that the puppet agent uses a different libdir than the puppet master.  You can do this by putting the following lines in your `puppet.conf`:

        [puppetd]
            libdir = $vardir/agent_lib

3.  Create a directory for custom report libraries, e.g. run the following command, but replace `LIBDIR` with the path you found in step 1:

        mkdir -p LIBDIR/puppet/reports/

    For example, if `puppetmasterd --configprint libdir` prints `/var/lib/puppet/lib`, then you should run:

        mkdir -p /var/lib/puppet/lib/puppet/reports/

4.  Create a custom report processor file on your Puppet Master by copying the Puppet Dashboard's `ext/puppet/puppet_dashboard.rb` file to `LIBDIR/puppet/reports`. E.g.,

        cp ext/puppet/puppet_dashboard.rb LIBDIR/puppet/reports

    This report processor will assume that your Puppet Dashboard server is running at `localhost` on port `3000`, which is the default if it was started using `script/server`. If you need to specify different values, edit the `ext/puppet/puppet_dashboard.rb` file.

    *NOTE:* In Puppet Dashboard versions prior to 1.0.3, this file was located at `lib/puppet/puppet_dashboard.rb`

5.  Add a `puppet_dashboard` value to the `reports` setting in the `[puppetmasterd]` section of your `puppet.conf` file, e.g.:

        [puppetmasterd]
          reports = puppet_dashboard

6.  Restart the `puppetmasterd` process.

#### Puppet 2.6.x

##### On your clients

1.  Make your clients send reports by setting `report` to `true` in the `[agent]` block of your `puppet.conf`, e.g.:

        [agent]
          report = true

    *NOTE:* The `puppet.conf` block name changed in 2.6.x from `[puppetd]` to `[agent]`

##### On your Puppet Master

1.  Modify your Puppet Master to send reports to the Puppet Dashboard. Do this by adding an `http` value to the `reports` setting in the `master` section of your `puppet.conf` file. For example, a `puppet.conf` for sending reports to a Puppet Dashboard server running at `localhost` on port `3000` may look like:

        [master]
          reports = http, store

    If your Puppet Dashboard is at a different hostname or port, specify a `reporturl` setting with its URL, e.g.:

        [master]
          reports = http, store
          reporturl = http://mydashboard.server:1234/reports/upload

    *NOTE:* The `/reports/upload` portion of the `reporturl` is required.

2.  Restart the `puppetmasterd` process.


External node classification
----------------------------

The Puppet Dashboard can act as an external node classification tool, which will allow you to manage Puppet classes and parameters for your nodes using a web interface:

1.  Modify your Puppet Master's `puppet.conf` file by adding lines like these:

        [puppetmasterd]
          node_terminus  = exec
          external_nodes = /opt/dashboard/bin/external_node

    Set the `external_nodes` value to the absolute path of the Puppet Dashboard's `bin/external_node` program. If the Puppet Dashboard is running on a different computer, you should copy this file to the Puppet Master to a local directory like `/etc/puppet` and specify the path to it.

    The `bin/external_node` program connects to the Puppet Dashboard at `localhost` on port `3000`. If your Puppet Dashboard is running on a different host or node, please modify this file.

    If you have Dashboard set up to use HTTPS, change the DASHBOARD_URL in `external_node` to the `https` prefix and the correct port number (443, by default). You may also need to change the CERT_PATH, PKEY_PATH, and CA_PATH variables if your puppet master's hostname is not `puppet` or if your ssldir is not `/etc/puppet/ssl`.

    If you would prefer not to edit the external_node script, you may override these settings using environment variables: PUPPET_DASHBOARD_URL, PUPPET_CERT_PATH, PUPPET_PKEY_PATH, PUPPET_CA_PATH. For example:
        [puppetmasterd]
          node_terminus  = exec
          external_nodes = /usr/bin/env PUPPET_DASHBOARD_URL=http://dashboard.localdomain:8000 /opt/dashboard/bin/external_node


2.  Restart the `puppetmasterd` process.

Security
--------

*WARNING:* The Puppet Dashboard provides access to sensitive information and can make changes to your Puppet-managed infrastructure. You must restrict access to it to protect it!

The Puppet Dashboard does not currently provide authentication or authorization -- although work on these is in progress.

Third-party tools that can help secure a Puppet Dashboard include:

1.  Host firewalling (e.g. `iptables`) can limit what hosts can access to the port that the Puppet Dashboard runs on, for example, only allowing the computer running the Puppet Master to connect.

2.  Tunneling (e.g. `stunnel` or `ssh`) can provide an encrypted connection between hosts, e.g. if the Puppet Master and Puppet Dashboard are running on separate hosts, or if you want to access the web interface from your workstation.

3.  HTTP Basic Authentication proxy (e.g. `apache` using `.htaccess`) can require that a username/password is provided when accessing URLs. However, if you use this, you must include the HTTP Basic Authentication username and password in the URLs in the `puppet.conf` file's `reporturl` setting and in the `bin/external_nodes` file. A URL with HTTP Basic Authentication has the following format:

        http://username:password@hostname

4.  HTTPS (SSL) Encryption is supported when running Dashboard under Apache and Passenger. The example configuration in `ext/passenger/dashboard-vhost.conf` includes a commented-out vhost configured to use SSL. You may need to change the Apache directives SSLCertificateFile, SSLCertificateKeyFile, SSLCACertificateFile, and SSLCARevocationFile to the paths of the files created by the `cert` rake tasks. (See `Generating certs and connecting to the puppet master` for how to create these files)

Performance
-----------

The Puppet Dashboard slows down as it manages more data. Here are ways to make it run faster, from easiest to hardest:

*  Optimize your database by running `rake RAILS_ENV=production db:raw:optimize` from your Puppet Dashboard directory, this will reorganize and reanalyze your database for faster queries.
*  Run the application in `production` mode, e.g. by running `./script/server -e production`. The default `development` mode is significantly slower because it doesn't cache and logs more details.
*  Run the application using multiple processes to handle more concurrent requests. You can use Phusion Passenger, or clusters of Thin or Unicorn servers to serve multiple concurrent requests.
*  Prune your old reports, see the "Database cleanup" section in this document.
*  Run on a machine with a fast, local database.
*  Run on a machine with enough processing power and memory.
*  Run on a machine with fast backplane, controllers and disks.

Debugging
---------

The Puppet Dashboard may not start or may display warnings if misconfigured or if it encounters an error. Details about these errors are recorded to log files that will help diagnose and resolve the problem.

You can find the logs in the `log` subdirectory of the Puppet Dashboard install, which will probably be in `/usr/share/puppet-dashboard/log/{environment}.log` if you installed from a package. You may want to customize your log rotation in `config/environment.rb`, if you would like to devote more or less disk to archival of logs.

If you installed from source, it will be wherever you cloned your git repository.

If you're running Puppet Dashboard using Apache and Phusion Passenger, the Apache logs will contain higher-level information, like severe errors describing why the Passenger application couldn't start if it couldn't write to its logs.

Database backups
----------------

The Puppet Dashboard database can be backed up and restored using your database vendor's tools, or using the included `rake` tasks which simplify the process. You must `cd` into the directory with the Puppet Dashboard software containing this `README.markdown` file before running these commands.

### Dump

To dump the Puppet Dashboard `production` database to a file called `production.sql`:

    rake RAILS_ENV=production db:raw:dump

Or dump it to a specific file:

    rake RAILS_ENV=production FILE=/my/backup/file.sql db:raw:dump

### Restore

To restore the Puppet Dashboard from a file called `production.sql` to your `production` environment:

    rake RAILS_ENV=production FILE=production.sql db:raw:restore

Database cleanup
----------------

Reports will build up over time which you may want to delete because of space or data retention policy issues. A `rake` task is included to help with this, and as with the other `rake` tasks it should be run from the same directory as this `README.markdown` file is in.

For example, to delete reports older than 1 month:

    rake RAILS_ENV=production reports:prune upto=1 unit=mon

If you run 'rake reports:prune' without any arguments, or incorrect arguments, it will display further usage instructions.

Generating certs and connecting to the puppet master
----------------------------------------------------

In order to connect to the puppet master (to retrieve node facts), the Dashboard must be configured with the correct SSL certificates.  To do this, run the following commands:

    rake cert:create_key_pair

    rake cert:request

Then instruct the master to sign the certificate request (using "puppet cert"), and then run the command:

    rake cert:retrieve

You will also need to configure auth.conf on the master to allow Dashboard to connect to the facts terminus:

    path /facts
    method find
    allow dashboard

Using the Inventory Service Custom Queries
----------------------------------------------------

In order to connect to the inventory service you will need to configure auth.conf on the puppet master running the inventory service to allow Dashboard to connect to the inventory terminus:

    path /inventory
    method search
    allow dashboard

Contributors
------------

* Rein Henrichs <reinh@reinh.com>
* Igal Koshevoy <igal@pragmaticraft.com>
* Rick Bradley <rick@rickbradley.com>
* Andrew Maier <andrew.maier@gatech.edu>
* Scott Smith <scott@ohlol.net>
* Ian Ward Comfort <icomfort@stanford.edu>
* Matt Robinson <matt@puppetlabs.com>
* Nick Lewis <nick@puppetlabs.com>
* Jacob Helwig <jacob@puppetlabs.com>
* Paul Berry <paul@puppetlabs.com>
