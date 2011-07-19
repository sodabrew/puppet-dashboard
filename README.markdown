Puppet Dashboard
================

Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/). It can view and analyze Puppet reports, assign Puppet classes and parameters to nodes, and view inventory data and backed-up file contents. 

For full documentation, see the [Puppet Dashboard 1.2 Manual](http://docs.puppetlabs.com/dashboard/manual/1.2).

Dependencies
------------

* Ruby 1.8.7
* RubyGems
* Rake >= 0.8.3
* MySQL server 5.x
* Ruby-MySQL bindings 2.7.x or 2.8.x

Fast Install
------------

* Check out the code.
* Edit your `config/settings.yml` and `config/database.yml` files.
* Create a MySQL database and user, and set `max_allowed_packet` to 32M.
* `rake db:migrate`
* Start the Dashboard web server.
* Set up Puppet to be Dashboard-aware.
* Start the delayed job worker processes.

For detailed installation, setup, and usage instructions, see the [Puppet Dashboard 1.2 Manual](http://docs.puppetlabs.com/dashboard/manual/1.2). 

Icons
-----

Puppet Dashboard uses Mark James' fine [Silk icons](http://www.famfamfam.com/lab/icons/silk/).

Thanks, Mark!

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
