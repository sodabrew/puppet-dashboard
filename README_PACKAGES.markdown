Puppet Dashboard Packages
=========================

DEB and RPM packages for Puppet Dashboard are available via APT and Yum
repositories hosted by Puppet Labs.

DEB Packages via APT
--------------------

### Installation

1.  Add the following to your `/etc/apt/sources.list` file:

        deb http://apt.puppetlabs.com/ubuntu lucid main
        deb-src http://apt.puppetlabs.com/ubuntu lucid main

2.  Add the Puppet Labs repository key to APT by running:

        gpg --recv-key 4BD6EC30
        gpg -a --export 4BD6EC30 | sudo apt-key add -

3.  Update APT's package cache:

        sudo apt-get update

4.  Install Puppet Dashboard package:

        sudo apt-get install puppet-dashboard

5.  Configure `/etc/puppet-dashboard/database.yml`.

6.  Modify `/etc/default/puppet-dashboard`:

        enabled=1

Puppet Dashboard will be installed in `/usr/share/puppet-dashboard` and you can
start it via `service puppet-dashboard start`.

### Upgrading

1.  Update APT's package cache:

       sudo apt-get update

2.  Upgrade just Puppet Dashboard:

       sudo apt-get install puppet-dashboard

3.  Run the database migrations.  See `README.markdown` for more
    information.

4.  Restart your Puppet Dashboard server for these changes to take effect,
    which may require restarting your webserver.

RPM packages via Yum
--------------------

### Installation

1.  Create a Yum repo entry for Puppet Labs in
    `/etc/yum.repos.d/puppetlabs.repo`:

        [puppetlabs]
        name=Puppet Labs Packages
        baseurl=http://yum.puppetlabs.com/base/
        enabled=1
        gpgcheck=1
        gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs

2.  Install Puppet Dashboard via Yum:

        sudo yum install puppet-dashboard

You will be prompted to install the Puppet Labs release key as part of the
installation process.

Puppet Dashboard will be installed in `/usr/share/puppet-dashboard` and you can
start it via `service puppet-dashboard start`.

### Upgrading

1.  Upgrade Puppet Dashboard via Yum:

        sudo yum update puppet-dashboard

2.  Run the database migrations.  See `README.markdown` for more information.

3.  Restart your Puppet Dashboard server for these changes to take effect,
    which may require restarting your webserver.
