# Puppet Dashboard

## Overview

The Puppet Dashboard is a Puppet web interface that provides node
management and reporting tools. Nodes can be exported in YAML format, allowing the dashboard to be used as an external node classification tool.

## Dependencies

* ruby >= 1.8.1
* rake >= 0.8.4
* mysql

## Installation

1. **Obtain the source:** `git clone git://github.com/reductivelabs/puppet-dashboard.git`

2. **Configure the database:** `rake install`

3. **Start the server:** `script/server`

This will start a local Puppet Dashboard server on port 3000. As a Rails application, Puppet Dashboard can be deployed in any server configuration that Rails supports. Instructions for deployment via Phusion Passenger coming soon.

Note: Puppet Dashboard is configured to use a MySQL database by default. Consult the Rails Guides section on [Configuring A Database](http://guides.rubyonrails.org/getting_started.html#configuring-a-database) for information on how to set up a different database.

## Reporting

To enable report aggregation in Puppet Dashboard, the file `lib/puppet/puppet_dashboard.rb` must be available in Puppet's lib path. The easiest way to do this is to add `RAILS_ROOT/lib/puppet` to `$libdir` in your `puppet.conf`, where `RAILS_ROOT` is the directory containing this README. Then ensure that your puppetmasterd runs with the option `--reports puppet_dashboard`.

The puppet_dashboard report assumes that your Dashboard server is available at `localhost` on port 3000 (as it would be if you started it via `script/server`). For now, you will need to modify the constants in `puppet_dashboard.rb` if this is not the case.

## External Node Tool

Puppet Dashboard functions as an external node tool. All nodes make a puppet-compatible YAML specification available for export.

## Contributors

* Rein Henrichs - rein@reductivelabs.com
