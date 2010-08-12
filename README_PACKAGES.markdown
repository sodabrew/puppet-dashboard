Puppet Dashboard Packages
=========================

DEB and RPM packages for Puppet Dashboard are available via APT and Yum
repositories hosted by Puppet Labs.

DEB Packages via APT
--------------------

### Installation

1. Add the following to your /etc/apt/sources.list file:

       deb http://apt.puppetlabs.com/ubuntu lucid main
       deb-src http://apt.puppetlabs.com/ubuntu lucid main

2. Add the Puppet Labs repository key to APT.

       $ gpg --recv-key 8347A27F
       $ gpg -a --export 8347A27F | sudo apt-key add -

3. Run apt-get update

       $ sudo apt-get update

4. Install Puppet Dashboard package

       $ sudo apt-get install puppet-dashboard

The Dashboard will be installed in `/usr/share/puppet-dashboard` and you run
the server from here or create a Passenger configuration.

### Upgrading

1.  Run apt-get update

       $ sudo apt-get update

2.  Upgrade just Puppet Dashboard

       $ sudo apt-get install puppet-dashboard

3.  Run the database migrations.  See README.markdown for more information

4.  Restart your webserver

RPM packages via Yum
--------------------

### Installation

1. Create a Yum repo entry for Puppet Labs

       $ vi /etc/yum.repos.d/puppetlabs.repo

       [puppetlabs]
       name=Puppet Labs Packages
       baseurl=http://yum.puppetlabs.com/base/
       enabled=1
       gpgcheck=1
       gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-reductive

2. Install via yum

       $ sudo yum install puppet-dashboard

You will be prompted to install the Puppet Labs release key as part of the
installation process.

The Dashboard will be installed in `/usr/share/puppet-dashboard` and you run
the server from here or create a Passenger configuration.

### Upgrading

1. Upgrade via yum

       $ sudo yum update puppet-dashboard

2.  Run the database migrations.  See README.markdown for more information

3.  Restart your webserver
