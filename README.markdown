Puppet Dashboard
================

Puppet Dashboard is a web interface for [Puppet](http://www.puppetlabs.com/). It can view and analyze Puppet reports, assign Puppet classes and parameters to nodes, and view inventory data and backed-up file contents. 

For full documentation, see the [Puppet Dashboard 1.2 Manual](http://docs.puppetlabs.com/dashboard/manual/1.2).

Browser Support
---------------

* Chrome (current versions)
* Firefox 3.5 and higher
* Safari 4 and higher
* Internet Explorer 7 and higher

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

* Adrien Thebo <adrien@puppetlabs.com>
* Andreas Zuber <zuber@puzzle.ch>
* Andrew Maier <dev+andrewmaier@hashrocket.com>
* Bruno Leon <bruno.leon@savoirfairelinux.com>
* Carl Caum <carl@carlcaum.com>
* Chad Metcalf <chad@cloudera.com>
* Chris W <cwacek@gmail.com>
* Daniel Pittman <daniel@puppetlabs.com>
* Daniel Sauble <djsauble@puppetlabs.com>
* Danijel Ilisin <danijel.ilisin@sinnerschrader.com>
* Devon Harless <devon@puppetlabs.com>
* Evan Sparkman <evansparkman@esdezines.(none)>
* Ian Ward Comfort <icomfort@stanford.edu>
* Igal Koshevoy <igal@pragmaticraft.com>
* Jacob Helwig <jacob@puppetlabs.com>
* James Turnbull <james@puppetlabs.com>
* Jesse Wolfe <jes5199@gmail.com>
* Jonathan Grochowski <jonathan@puppetlabs.com>
* Josh Cooper <josh@puppetlabs.com>
* Joshua Harlan Lifton <lifton@puppetlabs.com>
* Matt Robinson <matt@puppetlabs.com>
* Matthaus Litteken <matthaus@puppetlabs.com>
* Max Martin <max@puppetlabs.com>
* Michael Stahnke <stahnma@puppetlabs.com>
* Moses Mendoza <moses@puppetlabs.com>
* Nick Fagerlund <nick.fagerlund@gmail.com>
* Nick Lewis <nick@puppetlabs.com>
* Nigel Kersten <nigel@puppetlabs.com>
* Patrick Carlisle <patrick@puppetlabs.com>
* Paul Berry <paul@puppetlabs.com>
* Peter Meier <peter.meier@immerda.ch>
* Pieter van de Bruggen <pieter@puppetlabs.com>
* Randall Hansen <randall@puppetlabs.com>
* Rein Henrichs <reinh@reinh.com>
* Richard Clamp <richardc@unixbeard.net>
* Rick Bradley <rick@rickbradley.com>
* Rob <rob@ldg.net>
* Saj Goonatilleke <sg@redu.cx>
* Scott Smith <scott@ohlol.net>
