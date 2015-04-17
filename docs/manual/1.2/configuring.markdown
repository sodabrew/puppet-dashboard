---
layout: default
title: "Dashboard Manual: Configuring"
---

Configuring Puppet Dashboard
=====

This is a chapter of the [Puppet Dashboard 1.2 manual](./index.html).

#### Navigation

* [Installing Dashboard](./bootstrapping.html)
* [Upgrading Dashboard](./upgrading.html)
* **Configuring Dashboard**
* [Maintaining Dashboard](./maintaining.html)
* [Using Dashboard](./using.html)
* [Rake API](./rake_api.html)

* * * 

Overview
--------

Now that you've [installed](./bootstrapping.html) Dashboard and prepared it for basic production-level use, you can configure it to:

* Enable advanced features
* Increase security
* Improve performance
* Install plugins

Note that **all rake tasks should be performed from a shell in the directory that contains Dashboard's code.** Any relative paths mentioned below refer to locations within this directory. If you are running Dashboard in the recommended "production" environment, note that **Rails does not consider production its default environment,** and you **must specify it manually** with the `RAILS_ENV` environment variable when running any rake tasks.

Advanced Features
---------

By default, Dashboard only responds to requests from a user or a puppet master. However, if you allow it to pull data from your puppet master, you can enable two extra features: the inventory service, and the file viewer.

### Generating Certs and Connecting to the Puppet Master

Puppet uses SSL certificates to control who can make requests to the puppet master, so Dashboard has to obtain a signed cert before asking for facts or files. To do this, edit `config/settings.yml` to ensure that the `ca_server` and `ca_port` settings match the address and port of your puppet master, then run the following commands:

    $ sudo -u puppet-dashboard rake cert:create_key_pair
    $ sudo -u puppet-dashboard rake cert:request

You'll need to sign the certificate request on the master by running `puppet cert sign dashboard`. Then, from Dashboard's directory again, run:

    $ sudo -u puppet-dashboard rake cert:retrieve

### Enabling Inventory Support

With inventory support, Dashboard can display a complete list of facts on each node's detail page. It also adds a new "Inventory Search" page which can search your entire site for nodes matching a fact query.

**Requirements:** To use the inventory, you must be using Puppet 2.6.7 or later, [configured to provide the inventory service][inventory]. If you are running Puppet 2.7.12 or later, you have the option of using [PuppetDB][pdb] instead of the `inventory_active_record` backend.

[pdb]: /puppetdb/latest/
[inventory]: /guides/inventory_service.html

Once the puppet master is properly configured with a database-backed inventory, edit your puppet master's [`auth.conf`](/guides/rest_auth_conf.html) file to grant Dashboard find and search access to /facts:

    path /facts
    auth yes
    method find, search
    allow dashboard

Then, edit Dashboard's `config/settings.yml` to set `enable_inventory_service` to `true` and point `inventory_server` and `inventory_port` to your puppet master. Restart Dashboard, and node pages should now contain lists of facts.

### Enabling the Filebucket Viewer

With the filebucket viewer, Dashboard can display the contents of different file versions when you click on MD5 checksums in reports. 

**Requirements:** To use the filebucket viewer, you must be using Puppet 2.6.5 or later  and your agent nodes must be configured to back up all files to a remote filebucket; this is done in your puppet master's `site.pp` manifest, where you must define a filebucket resource named "main"... 

    filebucket { "main":
      server => "{your puppet master}",
      path => false,
    }

...and set a global resource default of...

    File { backup => "main" }

If you are using inspect reports for a compliance workflow, you must also set `archive_files = true` in each agent's `puppet.conf`. 



Once the site manifest has been properly configured, edit Dashboard's `config/settings.yml` to set `use_file_bucket_diffs` to `true` and point `file_bucket_server` and `file_bucket_port` to your puppet master. Restart Dashboard, and you should be able to view the contents of any file mentioned in a report by clicking on its MD5 checksum. Diffs are not currently enabled, but will appear in a future version of Dashboard. 


Security
--------

As Dashboard provides access to sensitive information and can make changes to your Puppet-managed infrastructure, you'll need some way to restrict access to it. Dashboard does not yet provide authentication or authorization, so you'll need to use external tools to secure it. Some options include:

* **Host firewalling** --- The Dashboard server's firewall (e.g. `iptables`) can be used to limit which hosts can access the port Dashboard runs on.
* **`stunnel` or `ssh` tunneling** --- You can use tunneling to provide an encrypted connection between hosts, e.g. if the Puppet Master and Puppet Dashboard are running on separate hosts. It can also allow you to access the web interface from a workstation once you've restricted access by IP. 
* **HTTP Basic Authentication** --- When serving Dashboard via Apache, you can require a username and password to access its URLs by setting authentication rules for `/` in Dashboard's vhost configuration:

        <Location "/">
          Order allow,deny
          Allow from 192.168.240.110 # your puppet master's IP
          Satisfy any
          AuthName "Puppet Dashboard"
          AuthType Basic
          AuthUserFile /etc/apache2/htpasswd
          Require valid-user
        </Location>

    Notice that you need to leave an access exception for your puppet master(s). Although it's possible to configure Puppet to use a password when connecting to Dashboard (by [adding a username and password](http://en.wikipedia.org/wiki/URI_scheme#Generic_syntax) to Puppet's `reporturl` and the URL used by the `external_nodes` script), this currently requires patching Puppet's `http` report handler; see [issue 7173](http://projects.puppetlabs.com/issues/7173) for more details. 
* **HTTPS (SSL) Encryption** --- When serving Dashboard via Apache, you can encrypt traffic between Puppet and the Dashboard. Using this requires a set of signed certificates from the puppet master --- see [generating certs and connecting to the puppet master](#generating-certs-and-connecting-to-the-puppet-master) for how to obtain them. The example configuration in `ext/passenger/dashboard-vhost.conf` includes a commented-out vhost configured to use SSL. You may need to change the Apache directives `SSLCertificateFile`, `SSLCertificateKeyFile`, `SSLCACertificateFile`, and `SSLCARevocationFile` to the paths of the files created by the `cert` rake tasks. 

    If you have Dashboard set up to use HTTPS, you'll need to add an `https` prefix to the `DASHBOARD_URL` in the `external_node` script and potentially correct the port number (443, by default). You may also need to change the `CERT_PATH`, `PKEY_PATH`, and `CA_PATH` variables if your puppet master's hostname is not `puppet` or if your ssldir is not `/etc/puppet/ssl`.
    
    In order for reporting to work correctly via SSL, you will have to be running puppet master via Passenger or some other app server/webserver combination that can handle SSL; reporting to an SSL Dashboard is not supported when running puppet master under WEBrick. You'll also have to change the `reporturl` setting in `puppet.conf` to start with "https" instead of "http". 
    
    **This information may be outdated, and is currently being checked for accuracy.**

Performance
-----------

Puppet Dashboard slows down as it manages more data. Here are ways to make it run faster, from easiest to hardest:

* Run exactly one `delayed_job` worker per CPU core.
* [Make sure Dashboard is running in a production-quality web server](./bootstrapping.html#running-dashboard-in-a-production-quality-server), like Apache with Passenger.
* Make sure Dashboard is running in the production environment. Although Passenger runs Rails apps in production mode by default, other Rails tools may default to the much slower development environment.
* Optimize your database once a month; create a cron job that runs `rake RAILS_ENV=production db:raw:optimize` from your Puppet Dashboard directory. This will reorganize and reanalyze your database for faster queries.
* Tune the number of processes Dashboard uses to handle more concurrent requests. If you're using Apache with Phusion Passenger to serve Dashboard (as covered in the [Installing chapter](./bootstrapping.html#serving-dashboard-with-passenger-and-apache)), you can modify the appropriate settings in Dashboard's vhost file; in particular, pay attention to the `PassengerHighPerformance`, `PassengerMaxPoolSize`, `PassengerPoolIdleTime`, `PassengerMaxRequests`, and `PassengerStatThrottleRate` settings.
* Regularly prune your old reports; see ["cleaning old reports" in the maintenance chapter](./maintaining.html#cleaning-old-reports) for more details.
* Run on a machine with a fast, local database.
* Run on a machine with enough processing power and memory.
* Run on a machine with fast backplane, controllers, and disks.


Installing Plugins
----------

Puppet Labs plans to ship a variety of free and commercial plugins for Dashboard, which will add new features to support specific workflows. If you are installing a plugin, it probably came with official packages and its own installation instructions, but some general guidelines follow:

When installing a plugin from an official package, its files should be moved into the proper place with the proper ownership. However, you will probably have to run the `db:migrate` rake task after the installation is complete.

To install a plugin from source, rather than a package, you'll have to know the hardcoded internal name of the plugin. This should be listed in its documentation. Copy the plugin's directory to `vendor/plugins`, rename it to its proper internal name, and chown the directory and its files to the Dashboard user. Then, run the `puppet:plugin:install` task, passing the environment you're using[^pluginenv] and the name of the plugin as variables:

    $ sudo -u puppet-dashboard rake puppet:plugin:install PLUGIN=name RAILS_ENV=production

[^pluginenv]: `Puppet:plugin:install` runs `db:migrate` at the end. If you run in multiple environments regularly, you'll need to run `rake db:migrate` again for each additional one. 

After this, the plugin should be available and functioning. If you've been using Git to install and upgrade Dashboard, it should leave all plugin files untouched the next time you upgrade. 

### Uninstalling Plugins

This section will be filled in at a later date. 

* * * 

#### Navigation

* [Installing Dashboard](./bootstrapping.html)
* [Upgrading Dashboard](./upgrading.html)
* **Configuring Dashboard**
* [Maintaining Dashboard](./maintaining.html)
* [Using Dashboard](./using.html)
* [Rake API](./rake_api.html)

