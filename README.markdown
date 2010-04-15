# Puppet Dashboard

## Overview

The Puppet Dashboard is a Puppet web interface that provides node management and reporting tools. Nodes can be exported in YAML format, allowing the dashboard to be used as an external node classification tool.

## Dependencies

* ruby (built with iconv support) >= 1.8.1
* rake >= 0.8.3
* MySQL
* ruby mysql bindings (`gem install mysql` for ruby >= 1.8.6 or use your package manager's mysql-ruby package)

## Installation

1. **Obtain the source:** `git clone git://github.com/reductivelabs/puppet-dashboard.git`

2. **Configure the database:**

    1. `rake install`

    2. configure `config/database.yml` for your database

3. **Start the server:** `script/server`

4. **Import Reports (optional):** `rake reports:import`

**RedHat and CentOS users:** see [Install puppet-dashboard on RedHat/CentOS 5 : Mike Zupan&#039;s Random Blog](http://zcentric.com/2010/03/11/install-puppet-dashboard-on-redhatcentos-5/)

This will start a local Puppet Dashboard server on port 3000. As a Rails application, Puppet Dashboard can be deployed in any server configuration that Rails supports. Instructions for deployment via Phusion Passenger coming soon.

Note: Puppet Dashboard is currently MySQL only. Other databases coming soon.

## Reporting

### Report Import

To import puppet run reports stored in /var/puppet/lib/reports:

    rake reports:import

To specify a different report directory:

    rake reports:import REPORT_DIR=/path/to/your/reports

### Live report aggregation

To enable report aggregation in Puppet Dashboard, the file `lib/puppet/puppet_dashboard.rb` must be available in Puppet's lib path. The easiest way to do this is to add `RAILS_ROOT/lib/puppet` to `$libdir` in your `puppet.conf`, where `RAILS_ROOT` is the directory containing this README. Then ensure that your puppetmasterd runs with the option `--reports puppet_dashboard`.

The `puppet_dashboard` report assumes that your Dashboard server is available at `localhost` on port 3000 (as it would be if you started it via `script/server`). For now, you will need to modify the constants in `puppet_dashboard.rb` if this is not the case.

## External Node Tool

Puppet Dashboard functions as an external node tool. All nodes make a puppet-compatible YAML specification available for export. See `bin/external_node` for an example script that connects to Puppet Dashboard as an external node tool.

## Contributors

    Rein Henrichs <reinh@reinh.com>
    Rick Bradley <rick@rickbradley.com>
    Andrew Maier <dev+andrewmaier@hashrocket.com>
    Scott Smith <scott@ohlol.net>
    Ian Ward Comfort <icomfort@stanford.edu>
