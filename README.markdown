Puppet Dashboard
================

Overview
--------

The Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/), an open source system configuration management tool. The Puppet Dashboard currently displays reports with the detailed status and history of Puppet-managed servers (nodes), and can assign Puppet classes and parameters to them.

Source, community and support
-----------------------------

* [Puppet Dashboard source code](http://github.com/reductivelabs/puppet-dashboard)
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

*NOTE*: The following example instructions assume a fresh install of their respective operating systems. Your actual installation procedure may be different depending on your system's current configuration.

#### Ubuntu 10.04 LTS

1. Install the operating system packages:

       apt-get install -y build-essential irb libmysql-ruby libmysqlclient-dev libopenssl-ruby libreadline-ruby mysql-server rake rdoc ri ruby ruby-dev

2. Install the `gem` package manager -- do not use the one packaged with the operating system:

       URL="http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz"
       PACKAGE=$(echo $URL | sed "s/\.[^\.]*$//; s/^.*\///")
       pushd "/tmp"
         CACHE=`mktemp -d install_rubygems.XXXXXXXXXX`
         pushd "$CACHE"
           wget -c -t10 -T20 -q "$URL"
           tar xfz "$PACKAGE.tgz"
           cd "$PACKAGE"
           sudo ruby setup.rb
         popd
       popd

3. Create `gem` as an alternative name for the `gem1.8` command:

       update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.8 1

#### CentOS 5.5

1. Install the [Extra Packages for Enterprise Linux (EPEL)](http://fedoraproject.org/wiki/EPEL) repository for `yum`:

       rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm

2. Install the operating system packages:

       yum install -y mysql mysql-devel mysql-server ruby ruby-devel ruby-irb ruby-mysql ruby-rdoc ruby-ri

3. Start MySQL and make it start automatically at boot:

       service mysqld start
       chkconfig mysqld on

4. Install the `gem` package manager -- do not install RubyGems version 1.3.6 or newer because they are incompatible with the Ruby shipped with CentOS 5.5:

       URL="http://production.cf.rubygems.org/rubygems/rubygems-1.3.5.tgz"
       PACKAGE=$(echo $URL | sed "s/\.[^\.]*$//; s/^.*\///")
       pushd "/tmp"
         CACHE=`mktemp -d install_rubygems.XXXXXXXXXX`
         pushd "$CACHE"
           wget -c -t10 -T20 -q "$URL"
           tar xfz "$PACKAGE.tgz"
           cd "$PACKAGE"
           sudo ruby setup.rb
         popd
       popd

5. Install the `rake` gem:

       gem install rake

Installation
------------

1. Download the Puppet Dashboard software:

   1. Checkout the latest source code using the [Git](http://git-scm.com/) revision control system:

          git clone git://github.com/reductivelabs/puppet-dashboard.git

   2. Or install the software using APT or RPM packages. See `README_PACKAGES.markdown` for instructions.

2. Create a `config/database.yml` file to specify Puppet Dashboard's database configuration. Please see the `config/database.yml.example` file for further details about database configurations and environments. These files paths are relative to the path of the Puppet Dashboard software containing this `README.markdown` file.

3. Setup a MySQL database server, create a user and database for use with the Dashboard by either:

   1. Using a `rake` task to create just the database from settings in the `config/database.yml` file. You must `cd` into the directory with the Puppet Dashboard software containing this `README.markdown` file before running these commands:

          rake RAILS_ENV=production db:create

   2. Or creating the database, user and privileges manually by running `mysql` as a privileged user (e.g. `root`) and executing commands like:

          CREATE DATABASE dashboard CHARACTER SET utf8;
          CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'my_password';
          GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';

4. Populate the database with the tables for the Puppet Dashboard.

   1. For typical use with the `production` environment:

          rake RAILS_ENV=production db:migrate

   2. For developing the software using the `development` and `test` environments:

          rake db:migrate db:test:prepare

Upgrading
---------

### Code

If you installed the code from source and you want to run the latest code, from
the Puppet Dashboard source directory you can run

    git pull

If you prefer to run a specific version of Puppet Dashboard you can checkout a specific tag

    git fetch
    git checkout tag_name

And you can list the tag names with:

    git tag

If you installed from a package, your package management system should be able
to upgrade the code for you.  See README_PACKAGES.markdown for more info.

### Database Schema

Regardless of how you installed the code, after doing so you'll likely need to
run the database migrations to get your database schema up to date.  You'll
want to run this as the same user that you use to run Puppet Dashboard.

    RAILS_ENV=production rake db:migrate

After upgrading the code and running the migrations you'll need to restart your
webserver.

Running
-------

There are many ways to run a Ruby web application like the Puppet Dashboard, we recommend:

1. **Built-in webserver**: Ruby includes a built-in webserver that can run a single instance of the Puppet Dashboard application without any additional software. This is great for getting started quickly, but isn't recommended for production use because it's slow and can't handle multiple requests at the same time. You must `cd` into the directory with the Puppet Dashboard software containing this `README.markdown` file before running these commands:

   1. Start a `production` server on port 3000:

           ./script/server -e production

   2. Or start a `development` server on port 8080, where the `development` environment is used by default:

           ./script/server -p 8080

2. **Passenger**: This plugin for [Apache](http://httpd.apache.org/) or [Nginx](http://nginx.org/) makes it easy to multile Ruby web apps quickly and efficiently using multiple instances -- it's great for production use. If used along with Ruby Enterprise Edition, it can dramatically reduce the memry required to run Ruby web applications. For further information, please see [Passenger/](http://www.modrails.com/) and [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/) and the example apache configuration in `ext/passenger/dashboard-vhost.conf`.

3. **Thin**: This fast and reliable server can run multiple instances of the Puppet Dashboard application behind a proxy like [Apache](http://httpd.apache.org/) or [Nginx](http://nginx.org/) to appear as a single website -- it's great for production use. For further information, please see [Thin](http://code.macournoyer.com/thin/).

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

1. Make your clients send reports by setting `report` to `true` in the `[puppetd]` block of your `puppet.conf`, e.g.:

        [puppetd]
            report = true

##### On your Puppet Master

1. Identify your Puppet Master's `libdir` by running the following command, it will probably be `/var/lib/puppet`:

        puppetmasterd --configprint libdir

2. Create a directory for custom report libraries, e.g. run the following command, but replace `LIBDIR` with the path you found in step 1:

        mkdir -p LIBDIR/puppet/reports/

3. Create a custom report processor file on your Puppet Master by copying the Puppet Dashboard's `ext/puppet/puppet_dashboard.rb` file to `LIBDIR/puppet/reports`. E.g.,

        cp ext/puppet/puppet_dashboard.rb LIBDIR/puppet/reports

   This report processor will assume that your Puppet Dashboard server is running at `localhost` on port `3000`, which is the default if it was started using `script/server`. If you need to specify different values, edit the `ext/puppet/puppet_dashboard.rb` file.

   *NOTE:* In Puppet Dashboard versions prior to 1.0.3, this file was located at `lib/puppet/puppet_dashboard.rb`

5. Add a `puppet_dashboard` value to the `reports` setting in the `[puppetmasterd]` section of your `puppet.conf` file, e.g.:

        [puppetmasterd]
            reports = puppet_dashboard

6. Restart the `puppetmasterd` process.

#### Puppet 2.6.x

##### On your clients

1. Make your clients send reports by setting `report` to `true` in the `[agent]` block of your `puppet.conf`, e.g.:

        [agent]
            report = true

   *NOTE:* The `puppet.conf` block name changed in 2.6.x from `[puppetd]` to `[agent]`

##### On your Puppet Master

1. Modify your Puppet Master to send reports to the Puppet Dashboard. Do this by adding an `http` value to the `reports` setting in the `master` section of your `puppet.conf` file. For example, a `puppet.conf` for sending reports to a Puppet Dashboard server running at `localhost` on port `3000` may look like:

        [master]
            reports = http, store

   If your Puppet Dashboard is at a different hostname or port, specify a `reporturl` setting with its URL, e.g.:

        [master]
            reports = http, store
            reporturl = http://mydashboard.server:1234/reports

   *NOTE:* The `/reports` portion of the `reporturl` is required.

2. Restart the `puppetmasterd` process.


External node classification
---------------------------------------------

The Puppet Dashboard can act as an external node classification tool, which will allow you to manage Puppet classes and parameters for your nodes using a web interface:

1. Modify your Puppet Master's `puppet.conf` file by adding lines like these:

        [puppetmasterd]
          node_terminus  = exec
          external_nodes = /opt/dashboard/bin/external_node

   *NOTE:* Set the `external_nodes` value to the absolute path of the Puppet Dashboard's `bin/external_node` program. If the Puppet Dashboard is running on a different computer, you should copy this file to the Puppet Master to a local directory like `/etc/pupppet` and specify the path to it.

   *NOTE:* The `bin/external_node` program connects to the Puppet Dashboard at `localhost` on port `3000`. If your Puppet Dashboard is running on a different host or node, please modify this file.

2. Restart the `puppetmasterd` process.

Security
--------

*WARNING:* The Puppet Dashboard provides access to sensitive information and can make changes to your Puppet-managed infrastructure. You must restrict access to it to protect it!

The Puppet Dashboard does not currently provide authentication, authorization or encryption -- although work on these is in progress.

Third-party tools that can help secure a Puppet Dashboard include:

1. Host firewalling (e.g. `iptables`) can limit what hosts can access to the port that the Puppet Dashboard runs on, for example, only allowing the computer running the Puppet Master to connect.

2. Tunneling (e.g. `stunnel` or `ssh`) can provide an encrypted connection between hosts, e.g. if the Puppet Master and Puppet Dashboard are running on separate hosts, or if you want to access the web interface from your workstation.

3. HTTP Basic Authentication proxy (e.g. `apache` using `.htaccess`) can require that a username/password is provided when accessing URLs. However, if you use this, you must include the HTTP Basic Authentication username and password in the URLs in the `puppet.conf`'s `reporturl` setting and in the `bin/external_nodes` file. A URL with HTTP Basic Authentication has the following format:

            http://username:password@hostname

Debugging
---------

The log files will contain a lot of useful information to help you debug
problems you might have.  You can find the logs in the log subfolder of the
Puppet Dashboard install, which if you installed from packages is probably
/usr/share/puppet-dashboard/log/{environment}.log

If you installed from source it will be wherever you cloned your git
repository.

If you're running Puppet Dashboard using Apache and Phusion Passenger the
Apache logs will contain Puppet Dashboard's logging.

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

Reports will build up over time which you may want to delete because of space
or data rentention policy issues.  A rake task is included to help with this,
and as with the other rake tasks it should be run from the same directory
this README.markdown file is in.

### Prune

To delete reports older than 1 month:

    rake RAILS_ENV=production reports:prune upto=1 unit=mon

If you run 'rake reports:prune' without any arguments or incorrect arguments it
will print the available units.

Contributors
------------

* Rein Henrichs <reinh@reinh.com>
* Igal Koshevoy <igal@pragmaticraft.com>
* Rick Bradley <rick@rickbradley.com>
* Andrew Maier <andrew.maier@gatech.edu>
* Scott Smith <scott@ohlol.net>
* Ian Ward Comfort <icomfort@stanford.edu>
* Matt Robinson <matt@puppetlabs.com>
