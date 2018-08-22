---
layout: default
title: Dashboard Under Passenger
---

Running Puppet Dashboard With Apache and Passenger
======

Although Dashboard can serve itself using Ruby's built-in WEBrick server, it performs more reliably under Apache with [Phusion Passenger][passenger]. **This document is deprecated. For up-to-date information, see the [bootstrapping chapter](/dashboard/manual/1.2/bootstrapping.html#running-dashboard-in-a-production-quality-server) of the latest version of the Puppet Dashboard manual.**

[passenger]: http://www.modrails.com/
[pass-guide]: http://www.modrails.com/documentation/Users%20guide%20Apache.html
[passinstall]: http://www.modrails.com/install.html

* * * 

Anything Works
--------------

Puppet Dashboard is a fairly typical Ruby on Rails application. There are a LOT of good ways to serve a Rails app, and this is only one of them; if you follow the instructions for getting it running under something else, you will probably be perfectly happy with the results. That said, here's the way we do it:

Prerequisites
-------------

### Install Apache 2.2

You are almost certainly going to want to use the packages provided by your OS vendor. It's probably already installed on this machine anyway. Enough said.

### Install and Enable Passenger

The Passenger website has [installation instructions][passinstall], but it's quite possible that your OS vendor has packages for Passenger as well. Use your best judgment.

Re-chown Any Dashboard Files Owned By Other Users
-------------------------------------------------

If you've ever run Dashboard under the default WEBrick server, there's a good chance that its log files (and its certificates if you're using the inventory or filebucket features) are owned by root, or someone else who isn't Dashboard's user. Do a quick pass through Dashboard's directory and give it ownership of any files that may have slipped away. 

Also, make sure you kill WEBrick if it's still running. 

Configure Dashboard's Vhost
---------------------------

As ever, there's an easy way and a less easy way.

#### The Easy Way: Copy and Edit the Example Vhost Config

Dashboard ships with an example vhost configuration file for running under Passenger, which can be found at `ext/dashboard-vhost.conf` in the Dashboard source. Simply copy it to Apache's `conf.d` directory and edit the relevant lines, which are commented with reminders. Specifically, you'll need to set: 

* **The port to serve Dashboard on.** This defaults to 80, but if you want to serve it on Dashboard's default of 3000, you'll need to change the opening tag of the vhost definition block to `<VirtualHost *:3000>` and prepend a `Listen 3000` directive in front of it. 
* **The URL you'll be serving Dashboard from,** which is generally just the FQDN of this machine. Put this in the `ServerName` directive.
* **The location of Dashboard's `public` directory,** which should go in the `DocumentRoot` directive and the `<Directory>` block opening tag. 
* **Your preferred log file locations,** which go in the `ErrorLog` and `CustomLog` directives. 
* **The paths to Passenger, `mod_passenger`, and Ruby.** But before you tweak these, scan the rest of Apache's config files: if you installed Passenger from a vendor package, it probably already inserted a file to make sure it's loaded, in which case you can safely comment out the first three lines of this vhost config. Otherwise point the `LoadModule`, `PassengerRoot`, and `PassengerRuby` directives to the correct files and directories. 

#### The Hard Way: You Already Know What You're Doing

So we won't belabor it. See the [Passenger user's guide][pass-guide] for any missing details. The take-away is that the `DocumentRoot` should point to Dashboard's `public` directory, which needs to allow all access and have the `MultiViews` option turned off. Passenger will need either the per-server `RailsAutoDetect` directive set to `On` (which is its default state), or a `RailsBaseURI` directive in the vhost definition. 

Restart Apache
--------------

And that's it; Dashboard should be available at your specified hostname and port. 
